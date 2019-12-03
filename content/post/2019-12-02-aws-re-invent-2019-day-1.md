---
title: AWS re:Invent 2019 - Day 1
author: Danny Morris
date: '2019-12-02'
slug: aws-re-invent-2019-day-1
categories:
  - AWS
tags:
  - AWS
---

The first day of AWS re:Invent 2019 is coming to a close. For me, today was mostly about using SageMaker to build and deploy deep learning models. In the first session, I used Tensorflow and Glove to train a text classifier from word vector representations. The primary focus was bringing custom Docker environments for training and inference. Some time at the beginning was spent discussing the major differences between traditional NLP pipelines and deep learning NLP pipelines. For instance, how traditional one-hot encoding does not scale well and does not capture word correlations. Vector representations overcome these issues. NLP pipelines based on deep learning also require essentially no feature engineering. The drawback to deep learning pipelines is the amount of data that is typically required for accurate learning. I am looking forward to experimenting with word embeddings and SageMaker to potentially improve a record linkage application I built for my company.

The next session involved building an object detection model from scratch using MXNet and GluonCV. The workshop focused primarily on using SageMaker for data labeling, automatic hyperparameter tuning, GPU training, and model deployment. I found MXNet very pleasant to use despite having not used it before. I found the parts about data labeling and hyperparameter tuning to be the most interesting. SageMaker has a few nice features for expediting data labeling, either through your own labeling or automatic labeling. Hyperparameter tuning was easy to set up and tuners run in parallel. The workshop leaders recommended Bayesian optimization as the parameter search strategy.

Finally, I finished off the day with a short session on using Textract to extract text from large batches of documents. I enjoyed learning about the deep learning strategies the AWS team deployed to enable accurate text extraction. Much of the information that was presented was not particularly new to me, however I left with some ideas on how to enhance some NLP projects my team at work is involved with.