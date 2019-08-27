---
title: Event-Driven Code Execution Using S3, Lambda, EC2, and R
author: Danny Morris
date: '2019-08-22'
slug: event-driven-code-execution-using-s3-lambda-ec2-r
categories:
  - AWS
tags:
  - AWS
---

This document outlines the steps to using S3 events to trigger a Lambda function that starts up an EC2 instance, executes a custom R script on the instance, then stops the instance. 

# Pipeline Overview

![](/img/analysis-function-pipeline.PNG)

1. A file is uploaded to an S3 bucket.

2. The file upload triggers a Lambda function that starts an EC2 instance, runs an R script, and stops the EC2 instance.

3. When run, the R script returns the output to an S3 bucket.

# EC2 Configuration Overview

1. Launch Amazon Linux AMI

2. Configure roles, policies, and access keys

3. Install R and RStudio Server

4. Create and save R script that reads/write to S3

5. Stop instance

# Launch and Configure EC2 Instance

Build an EC2 instance containing the necessary applications to run code (e.g. R/Python script). The instance can be built manually, from a bootstrap, or from a Docker image. This document demonstrates a manual build.

### Launch Amazon Linux AMI

![](/img/ec2-linux-ami.PNG)

### Connect via ssh

```
ssh -i "path/to/pem_file" ec2-user@<INSTANCE_DNS>

# switch to root user
sudo su -
```

### Configure Access

This may require setting access keys.

```
aws configure
```

### Install required software

Python is pre-installed. The following code installs a version of R that AWS supports. At the time of this writing it is version 3.4.1 (latest is greater than 3.6.0). The gap between versions is only significant if you need the latest content developed in R.

```
sudo yum update

# Install R
sudo amazon-linux-extras install R3.4
sudo yum install openssl-devel
sudo yum install libcurl-devel
sudo yum install libxml2-devel

# Install RStudio Server
wget https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-1.2.1335-x86_64.rpm
yum install -y --nogpgcheck rstudio-server-rhel-1.2.1335-x86_64.rpm

# Add rstudio user
sudo useradd rstudio
echo rstudio:rstudio | chpasswd

# Install Python 3.7 (not needed)
sudo yum install python37

# Install pip (not needed)
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py

# Install Anaconda (not needed)
sudo yum install libXcomposite libXcursor libXi libXtst libXrandr alsa-lib mesa-libEGL libXdamage mesa-libGL libXScrnSaver
wget https://repo.continuum.io/archive/Anaconda2-4.1.1-Linux-x86_64.sh
bash what_Anaconda_you_downloaded_Linux_x86_64.sh
source .bashrc
```

### Install R Packages and Code

Visit port 8787 of the instance DNS to access RStudio Server. Setting up the R environment is best done through RStudio Server.

```
install.packages("devtools", repos = "https://cran.rstudio.com")
install.packages("aws.s3", repos = "https://cran.rstudio.com")
install.packages("aws.signature", repos = "https://cran.rstudio.com")
```

Add this script to /home/rstudio/R/app.R

```
# /home/rstudio/R/app.R

library(randomForest)

# Train and fit random forest
rand_forest <- randomForest(Species ~ ., data = iris)
fit_df <- data.frame(Actual = iris$Species,
                     Predicted = predict(rand_forest))
                     
write.csv(fit_df, "fit_df.csv")

# load to S3
# make sure the EC2 has a policy allowing for this
s3write_using(x = fit_df,
              FUN = write.csv,
              bucket = "emr-s3-poc",
              object = "fit_df.csv")
```

### Connect via SSH and run R code

```
cd /home/rstudio/R/
chmod 777 app.R

R -e "source('app.R')"
```

# Lambda Function

The Lambda function utilizes the Python 3.7 runtime. It starts the pre-configured EC2 instance, runs an R script, and stops the instance.

```
import boto3
import time
REGION = 'us-east-2'
INSTANCE_ID = ['i-0af26cc632eef2d90']

def start_ec2():
    ec2 = boto3.client('ec2', region_name=REGION)
    ec2.start_instances(InstanceIds=INSTANCE_ID)

    while True:
        response = ec2.describe_instance_status(InstanceIds=INSTANCE_ID, IncludeAllInstances=True)
        state = response['InstanceStatuses'][0]['InstanceState']

        print(f"Status: {state['Code']} - {state['Name']}")

        # If status is 16 ('running'), then proceed, else, wait 5 seconds and try again
        if state['Code'] == 16:
            break
        else:
            time.sleep(5)

    print('EC2 started')
    
def stop_ec2():
    ec2 = boto3.client('ec2', region_name=REGION)
    ec2.stop_instances(InstanceIds=INSTANCE_ID)

    while True:
        response = ec2.describe_instance_status(InstanceIds=INSTANCE_ID, IncludeAllInstances=True)
        state = response['InstanceStatuses'][0]['InstanceState']

        print(f"Status: {state['Code']} - {state['Name']}")

        # If status is 80 ('stopped'), then proceed, else wait 5 seconds and try again
        if state['Code'] == 80:
            break
        else:
            time.sleep(5)

    print('Instance stopped')

    
def run_command():
    client = boto3.client('ssm', region_name=REGION)

    time.sleep(10)  

    cmd_response = client.send_command(
        InstanceIds=['i-0af26cc632eef2d90'],
        DocumentName='AWS-RunShellScript',
        DocumentVersion="1",
        TimeoutSeconds=300,
        MaxConcurrency="1",
        CloudWatchOutputConfig={'CloudWatchOutputEnabled': True},
        Parameters={
            'commands': ["sudo su rstudio", "cd ../../home/rstudio/", "R -e 'getwd()'", "Rscript R/app.R"],
            'executionTimeout': ["300"]
        },
    )

    command_id = cmd_response['Command']['CommandId']
    time.sleep(1)  

    retcode = -1
    while True:
        output = client.get_command_invocation(
            CommandId=command_id,
            InstanceId='i-0af26cc632eef2d90',
        )

        retcode = output['ResponseCode']
        if retcode != -1:
            print('Status: ', output['Status'])
            print('StdOut: ', output['StandardOutputContent'])
            print('StdErr: ', output['StandardErrorContent'])
            break

        print('Status: ', retcode)
        time.sleep(5)

    print('Command finished successfully') 
    return retcode


def lambda_handler(event, context):
    retcode = -1
    try:
        start_ec2()
        retcode = run_command()
    finally:  # Independently of what happens, try to shutdown the EC2
        stop_ec2()
        print("Function complete.")

    return retcode 
```

# Trigger Lambda on S3 Event

Configure the Lambda function to execute when a file is placed in <BUCKET_NAME>/<PREFIX>

![](/img/lambda-add-trigger-config.PNG)

# Configure IAM Role

The IAM role requires permissions to execute Lambda, start and stop EC2 instances, and send commands to EC2 using SSM. Full access to these three services is optional.

![](/img/ec2/iam.PNG)



