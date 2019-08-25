---
title: Launch RStudio Server on AWS EMR Cluster
author: Danny Morris
date: '2019-08-11'
slug: launch-rstudio-server-on-aws-emr-cluster
categories:
  - AWS
  - RStudio Server
  - EMR
  - R
tags:
  - EMR
  - AWS
  - R
  - RStudio Server
---

This post documents the steps to launch RStudio Server on an [AWS EMR](https://aws.amazon.com/emr/) cluster.

Reference: [Using sparklyr with an Apache Spark cluster](https://spark.rstudio.com/examples/yarn-cluster-emr/)

1. Open AWS Console and navigate to the EMR service

2. Select "Create cluster"

3. Select "Go to advanced options" to customize the cluster configuration

4. Under "Software Configuration", select Spark. Other applications can be selected as needed. Click Next.

5 . Configure the hardware requirements as needed and click Next.

6. Give the cluster a name and select an S3 bucket for logging. Click Next.

7. Select an existing EC2 key-pair or create a new one. Under EC2 Security Groups, select a group with ports 22 and 8787 open to inbound traffic. Select Create cluster.

8. SSH into the cluster

9. Install RStudio Server

```
cat etc/system-release

# Update and install openssl-devel for use with devtools
sudo yum update
sudo yum install libcurl-devel openssl-devel # used for devtools

# Install RStudio Server
wget -P /tmp https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-1.2.1335-x86_64.rpm
sudo yum install --nogpgcheck /tmp/rstudio-server-rhel-1.2.1335-x86_64.rpm

# Make User and set password (must be a strong password to be accepted)
sudo useradd -m rstudio-user
sudo passwd rstudio-user
```

10. Optional: Follow the remaining steps in [Using sparklyr with an Apache Spark cluster](https://spark.rstudio.com/examples/yarn-cluster-emr/) to copy data into HDFS and perform statistical analysis.

# Bootstrap Actions

Coming soon...



