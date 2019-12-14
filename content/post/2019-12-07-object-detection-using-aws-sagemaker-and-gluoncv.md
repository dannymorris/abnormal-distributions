---
title: 'Object Detection Using AWS SageMaker and GluonCV '
author: Danny
date: '2019-12-07'
slug: object-detection-using-aws-sagemaker-and-gluoncv
categories:
  - AWS
  - Computer Vision
tags:
  - AWS
  - Computer Vision
---

This post briefly describes how I built an object detection model using AWS SageMaker and GluonCV to detect Blue Cross Blue Shield logos. Full code and notebooks can be found in the [GitHub repo](https://github.com/dannymorris/gluoncv-logo-detection).

### Collecting and preparing training images

To collect images for training, I searched Google for "bluecross blueshied logo", "bluecross blueshield letter", "bluecross blueshield building", "bluecross blueshield shirt", "bluecross blueshield event", "bluecross blueshield shirt", and "bluecross blueshield bus". I ended up with 400 images for training and validation.

The raw images were stored in an S3, then I used OpenCV to convert raw images to gray scale. I am not entirely sure how important this step was, but I decided that I was only interesetd in capturing the shape of the logo without respect for color. The gray scale images were put into the S3 bucket.

![](/img/bcbs-logo-sample-gray.PNG)

### Labeling images with bounding box

AWS Ground Truth is a useful service for labeling training data. [This article](https://aws.amazon.com/getting-started/tutorials/build-training-datasets-amazon-sagemaker-ground-truth/) walks through the basic steps to labeling images using Grouth Truth.

![](/img/bcbs-logo-sample-label.PNG)

### Training

To train the model, I launched a ml.t2.medium SageMaker Notebook instance and connected to a conda_mxnet_p36 kernel. Getting started with MXNet and GluonCV could not have been easier using the fully managed SageMaker notebooks and kernels.

I elected to use the pre-trained weights from a [MobileNet SSD](https://arxiv.org/pdf/1704.04861.pdf) network, while replacing the pre-trained output layer with a new output layer that predicts my custom class (BCBS logos). GluonCV includes MobileNet as one of its pre-trained models for object detection, making it very easy to get started with this network. MobileNets are lightweight neural networks for computer vision applications. They have significantly fewer parameters compared to popular models for similar applications, making them more efficient for training and prediction at the cost of minimal reduction in accuracy.

I trained the network using a single GPU instance (ml.p3.2xlarge).

### Evaluation

Different loss functions can be used on a validation set to evaluate object detection models. For this application, I followed the recommendation of GluonCV and monitored the "Smooth L1" loss. This is a simple regression loss that compares the four numbers that make up the ground truth bounding box to the four numbers that make up the predicted bounding box. In my final training job, I obtained a Smooth L1 loss of 0.599 after 19 epochs.

![](/img/bcbs-logo-inference-shirt.PNG)

![](/img/bcbs-logo-inference-member-card.PNG)

![](/img/bcbs-logo-inference-building.PNG)


### Deployment

SageMaker makes it easy to deploy models as endpoints with just a few lines of code. In a production setting, this model endpoint could be invoked directly or placed behind an API Gateway.

```
mxnet_estimator.deploy(
    instance_type='ml.m5.xlarge', 
    initial_instance_count=1,
    endpoint_name="bcbs-logo-detection"
)
```

