---
title: 'Object Detection Using AWS SageMaker and GluonCV '
author: Danny Morris
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

To collect images for training, I searched Google for "bluecross blueshied logo", "bluecross blueshield letter", "bluecross blueshield building", "bluecross blueshield shirt", "bluecross blueshield event", "bluecross blueshield shirt", and "bluecross blueshield bus". The logos in the images varied in size, shape, angle, clarity, and background. I ended up with 400 images for training and validation. The raw, unlabeled images were stored in an S3 bucket

To prepare the images for training, I used OpenCV to convert raw images to gray scale. The effectiveness of gray scale coversion is debatable, but I decided that I was only interesetd in capturing the shape of the logo without respect for color. The gray scale images were put into the S3 bucket.

```
# Python function that accepts raw image S3 key and creates a gray scale copy
def convert_to_gray(s3_key):
    # defining s3 bucket object
    s3 = boto3.client("s3")
    bucket_name = "bcbs-logo-training-images"
    # fetching object from bucket
    file_obj = s3.get_object(Bucket=bucket_name, Key=s3_key)
    # reading the file content in bytes
    file_content = file_obj["Body"].read()
    # creating 1D array from bytes data range between[0,255]
    np_array = np.fromstring(file_content, np.uint8)
    # decoding array
    image_np = cv2.imdecode(np_array, cv2.IMREAD_COLOR)
    # converting image from RGB to Grayscale
    gray = cv2.cvtColor(image_np, cv2.COLOR_BGR2GRAY)
    return gray
    
gray_imgs = list(map(convert_to_gray, keys))
```

Here is an example training image with an angled logo.

![](/img/bcbs-logo-sample-gray.PNG)

### Labeling images with bounding box

AWS Ground Truth is a useful service for labeling training data. [This article](https://aws.amazon.com/getting-started/tutorials/build-training-datasets-amazon-sagemaker-ground-truth/) walks through the basic steps to use Grouth Truth for image labeling. The result of Ground Truth is a "manifest file" that contains the S3 locations and bounding box annotations for the training images.

Here is an example labeled image.

![](/img/bcbs-logo-sample-label.PNG)

### Training

To train the model, I launched a ml.t2.medium SageMaker Notebook instance and connected to a conda_mxnet_p36 kernel. Getting started with MXNet and GluonCV could not have been easier using the fully managed SageMaker notebooks and kernels.

I elected to use the pre-trained weights from a [MobileNet SSD](https://arxiv.org/pdf/1704.04861.pdf) network, while replacing the pre-trained output layer with a new output layer that predicts my custom class (BCBS logos). GluonCV includes MobileNet as one of its pre-trained models for object detection, making it very easy to get started with this network. MobileNets are lightweight neural networks for computer vision applications. They have significantly fewer parameters compared to popular models for similar applications, making them more efficient for training and prediction at the cost of minimal reduction in accuracy.

I launched the training job on a single GPU instance (ml.p3.2xlarge).

```
mxnet_estimator = MXNet(entry_point = 'train_bcbs_logo_detection_ssd.py',
                        source_dir = 'entry_point',
                        role = role,
                        train_instance_type = 'ml.p3.2xlarge',
                        train_instance_count = 1,
                        framework_version = '1.4.0', 
                        py_version = 'py3')
                        

s3_train_data = 's3://bcbs-logo-training-images/gray_images'
s3_label_data = 's3://bcbs-logo-training-images/gray_images/labels/bcbs-logo-labeling/manifests/output/'

mxnet_estimator.fit({'train': s3_train_data, 'labels': s3_label_data})                       
```

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

