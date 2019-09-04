---
title: Using SageMaker Notebooks for Machine Learning Development
author: Danny Morris
date: '2019-09-01'
slug: using-sagemaker-notebooks-for-machine-learning
categories:
  - AWS
  - Machine learning
tags:
  - AWS
  - Machine Learning
---

Reference: https://docs.aws.amazon.com/sagemaker/latest/dg/howitworks-create-ws.html

This document highlights some of the benefits of using SageMaker notebooks for developing ML models.

SageMaker is an AWS-managed service that provides several tools for machine learning, including a development environment for machine learning based on Jupyter Notebook. 

## 1. Minimal configuration

You can launch a SageMaker notebook through the AWS Console with minimial configuration. Simply give the notebook a name, specifiy the instance type, then specify role and security options.

## 2. Supports Python, R, and Spark

Notebook kernels exist for Python, R (beta), and even PySpark.

## 2. Popular ML and deep learning libraries included

By default, SageMaker installs all packages that are part of Anaconda. SageMaker also installs Tensorflow, MXNet

## 3. Persist notebooks

You can persist your notebook files on the attached ML storage volume. The ML storage volume will be detached when the notebook instance is shut down and reattached when the notebook instance is relaunched. Items stored in memory will not be persisted.

## 4. Multiple users sharing the same cluster

## 5. Isolated notebooks

## 6. No additional charage

