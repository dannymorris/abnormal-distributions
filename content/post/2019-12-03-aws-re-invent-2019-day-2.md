---
title: AWS re:Invent 2019 - Day 2
author: Danny Morris
date: '2019-12-03'
slug: aws-re-invent-2019-day-2
categories:
  - AWS
tags:
  - AWS
---

Day 2 of re:Invent was not as busy and diverse as day 1 for me, but it was extremely valuable toward my preparation for the Machine Learning Certification exam.

The Machine Learning exam tests your knowledge of all aspects of the ML, including MLOps (training, tuning, deploying, monitoring), deep learning concepts, data storage, and data processing. The core services which are given the most attention on the exam include S3, Glue, EMR, Athena, Kinesis, SageMaker, and AI Services. Some of the main modeling concepts include HPO (hyperparameter optimization), feature engineering (e.g. one-hot encoding, word embeddings), and data labeling. Some of the main engineering concepts include S3 storage, stream and batch processing, Docker containerization, and managing model deployments. Fortunately, in the practice exam I tested well in all areas.

At the end of the night, I was able to attend a workshop in time series forecasting with Amazon Forecast. This AI service provided a "simple" API for running forecasting models using traditional models (e.g ARIMA), Facebook Prophet, or DeepAR. Unlike the alternatives, DeepAR uses a deep learning architecture. I feel this service could be very valuable, but the API is not simple and the terminology adopted by the product team is counter to what ML practitioners are accustomed to. For example, they use the term "predictor" to refer to a trained model. This term is traditionally refers to a feature which is used to predict some outcome. The workshop did not flow very well with many attendees expression confusion over the code provided in the sample notebooks. Hopefully the product team is aware of the challenges with the current API and makes some updates. Once the service becomes easier to use, I believe it will provide significant value. 
