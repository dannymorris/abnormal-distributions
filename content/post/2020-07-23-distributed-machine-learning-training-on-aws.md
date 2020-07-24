---
title: Distributed machine learning on AWS using the SageMaker SDK in Python
author: Danny Morris
date: '2020-07-23'
slug: distributed-machine-learning-training-on-aws
categories:
  - Machine Learning
  - AWS
  - Python
tags:
  - AWS
  - Machine Learning
  - Python
---

## Overview

I recently participated in the [M5 Forecasting - Accuracy](https://www.kaggle.com/c/m5-forecasting-accuracy) Kaggle competition to forecast daily sales for over 30,000 WalMart products. I had some initial struggles processing the data and training models in-memory, so I eventually turned to running distributed training jobs using AWS SageMaker.

This post outlines the basic steps required to run a distributed machine learning job on AWS using the SageMaker SDK in Python. The steps are broken down into the following:

- Distributed data storage in S3
- Distributed training using multiple EC2 instances
- Publishing a model
- Executing a Batch Transform job to generate predictions

## Distributed data storage

For distributed machine learning on AWS, training data can be stored in S3 as a single file or distributed across multiple files. An example of distributed data storage is shown below.

```
bucket
└───train
│   │   FOODS_1_001_CA_1_evaluation.csv
│   │   FOODS_1_001_CA_2_evaluation.csv
|   |   ...
└───eval
│   |   FOODS_1_001_CA_1_evaluation.csv
│   |   FOODS_1_001_CA_2_evaluation.csv
|   |   ...
```

Note: Some SageMaker algorithms (e.g. XGBoost) require no header row (i.e. no column names).

## Distributed training

Distributed training is possible whether or not the data is stored in a single file or multiple files. If it's stored in a single file, the training computations are distributed across the number of EC2 instances specified by the user. If the data is distributed, SageMaker can handle the data in one of two ways: 1) Fully number of EC2 instances specified by the user. Option 1 leads to slower training times and greater memory consumption, yet it likely produces more accurate models since each EC2 instance is seeing the full training data. Option 2 is faster and memory efficient yet slightly less accurate since each EC2 instance only sees a portion of the total training data. 

The following code sample launches a training job using the `create_training_job` function with the following specifications:

- XGBoost built-in SageMaker algorithm
- 15 EC2 instances forming the disributed compute environment
- Distributed training data in S3 is split equally across the 15 EC2 instances (i.e. each EC2 sees roughly 1/15th of the total training data) for fast training times.

Note: I recommend running this code in a fully managed SageMaker Notebook instance (e.g. ml.t2.medium) for easy setup.

```
#############
# Libraries #
#############

import boto3
from sagemaker import get_execution_role
import sagemaker.amazon.common as smac
import time
import json

########################
# S3 bucket and prefix #
########################

bucket = 'abn-distro'
prefix = 'm5_store_items'

####################
## Execution role ##
####################

role = get_execution_role()

#######################
## XGBoost container ##
#######################

from sagemaker.amazon.amazon_estimator import get_image_uri
container = get_image_uri(boto3.Session().region_name, 'xgboost')

#########################
## Training parameters ##
#########################

sharded_training_params = {
    "RoleArn": role,
    "AlgorithmSpecification": {
        "TrainingImage": container,
        "TrainingInputMode": "File"
    },
    "ResourceConfig": {
        "InstanceCount": 15,
        "InstanceType": "ml.m4.4xlarge",
        "VolumeSizeInGB": 10
    },
    "InputDataConfig": [
        {
            "ChannelName": "train",
            "ContentType": "csv",
            "DataSource": {
                "S3DataSource": {
                    "S3DataDistributionType": "ShardedByS3Key",
                    "S3DataType": "S3Prefix",
                    "S3Uri": "s3://{}/{}/train/".format(bucket, prefix)
                }
            },
            "CompressionType": "None",
            "RecordWrapperType": "None"
        },
    ],
    "OutputDataConfig": {
        "S3OutputPath": "s3://{}/{}/".format(bucket, prefix)
    },
    "HyperParameters": {
        "num_round": "3000",
        "eta": "0.1",
        "objective": "reg:tweedie",
        "tweedie_variance_power": "1.5",
        "eval_metric": "rmse",
        "rate_drop": "0.2",
        "min_child_weight": "7",
        "max_depth": "5",
        "colsample_bytree": "0.7",
        "subsample": "0.7"
    },
    "StoppingCondition": {
        "MaxRuntimeInSeconds": 18000
    }
}

#######################
## Training job name ##
#######################

sharded_job = 'm5-sharded-xgboost-' + time.strftime("%Y-%m-%d-%H-%M-%S", time.gmtime())
sharded_training_params['TrainingJobName'] = sharded_job

#########################
## Launch training job ##
#########################

region = boto3.Session().region_name
sm = boto3.Session().client('sagemaker')

sm.create_training_job(**sharded_training_params)

status = sm.describe_training_job(TrainingJobName=sharded_job)['TrainingJobStatus']
print(status)

sm.get_waiter('training_job_completed_or_stopped').wait(TrainingJobName=sharded_job)

status = sm.describe_training_job(TrainingJobName=sharded_job)['TrainingJobStatus']
print("Training job ended with status: " + status)

if status == 'Failed':
    message = sm.describe_training_job(TrainingJobName=sharded_job)['FailureReason']
    print('Training failed with the following error: {}'.format(message))
    raise Exception('Training job failed')
```

## Publish model

Once the training job has successfully completed, publish the model using the `create_model` function in the SageMaker SDK. The location of the S3 bucket that contains your model artifacts and and the registry path of the image that contains inference code are required to publish the model. Since the XGBoost algorithm is a built-in SageMaker algorithm, the image containing inference code is fully managed by AWS.

```
##################
## Create model ##
##################

region = boto3.Session().region_name
sm = boto3.Session().client('sagemaker')

# get XGBoost image
from sagemaker.amazon.amazon_estimator import get_image_uri
container = get_image_uri(boto3.Session().region_name, 'xgboost')

# specify desired model name and location of artifacts
model_name = 'm5-sharded-xgboost-2020-07-19-17-02-04'
model_url = 's3://abn-distro/m5_store_items/m5-sharded-xgboost-2020-07-19-17-02-04/output/model.tar.gz'

# create model
sharded_model_response = sm.create_model(
    ModelName=model_name,
    ExecutionRoleArn=role,
    PrimaryContainer={
        'Image': container,
        'ModelDataUrl': model_url
    }
)
```

## Launch Batch Transform

Batch Transform is a service for generating predictions for many records at once, such as a single CSV file with many rows. This is akin to batch data processing. Once the model is published, use the `create_transform_job` function to launch a Batch Transform inference job. The results (predictions) are stored in S3.

```
###############################
## Configure batch transform ##
###############################

# assign a name to job and specify model
batch_job_name = 'm5-sharded-xgboost-batch-transform'
model_name = 'm5-sharded-xgboost-2020-07-19-17-02-04'

# S3 location of input/output data
batch_input = 's3://path/to/inference/data/'
batch_output = 's3://path/for/predictions/'

# batch job request specs
batch_request = {
    "TransformJobName": batch_job_name,
    "ModelName": model_name,
    "BatchStrategy": "MultiRecord",
    "TransformOutput": {
        "S3OutputPath": batch_output
    },
    "TransformInput": {
        "DataSource": {
            "S3DataSource": {
                "S3DataType": "S3Prefix",
                "S3Uri": batch_input 
            }
        },
        "ContentType": "text/csv",
        "SplitType": "Line",
        "CompressionType": "None"
    },
    "TransformResources": {
            "InstanceType": "ml.m4.xlarge",
            "InstanceCount": 1
    }
}

################################
## Launch batch transform job ##
################################

sm.create_transform_job(**batch_request)
                            
while(True):
    response = sm.describe_transform_job(TransformJobName=batch_job_name)
    status = response['TransformJobStatus']
    if  status == 'Completed':
        print("Transform job ended with status: " + status)
        break
    if status == 'Failed':
        message = response['FailureReason']
        print('Transform failed with the following error: {}'.format(message))
        raise Exception('Transform job failed') 
    print("Transform job is still in status: " + status)    
    time.sleep(30) 
```

## Conclusion

Using AWS SageMaker, distributed data storage and distributed training eliminates the challenges of dealing with data and computations that are too large for in-memory processing.



