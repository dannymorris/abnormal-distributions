---
title: Data Science on AWS
author: Danny Morris
date: '2019-08-24'
slug: aws-tools-for-data-science
categories:
  - AWS
  - Data Science
tags:
  - AWS
  - Data Science
---

This document describes some common goals of data science and how they can be acheived with tools and services on AWS.

# General Principles

- Tools and services empower innovative data science
- Event driven
- Serverless*
- Accomodates big data
- Accomodates unstructured and binary data (e.g. images)

* Servers may be involved, but they are configured to run on events

# List of Tools

- S3
- Lambda
- API Gateway
- EC2
- EMR
- R
- Python
- Spark
- SageMaker
- RStudio Server
- Jupyter Notebook

# Data Science Goals

## 1. Batch Predictions

- Objective: Generate predictions for batches of data on a recurring basis.
- Tools: ETL tool (e.g. Alteryx), S3, Lambda, EC2, API Gateway, SageMaker, EMR, R, Python, Spark
- Low latency not required
- Example: Predicted customer engagement scores are refreshed nightly on a set schedule.

## 2. Real-time Predictions

- Objective: Generate predictions with low response time.
- Tools: UI framework (e.g Shiny), API Gateway, Lambda, SageMaker, EMR, Python
- Designed for low latency
- Example: Predicted customer satisfaction scores are generated after each phone call.

## 3. Recurring Analysis Functions

- Objective: Apply analytics to data on a recurring basis
- Tools: same as Batch Predictions
- Ideal for big data processing pipelines
- Example: Demand forecast models are retrained and executed nightly.

## 4. Exploratory Data Analysis

- Objective: Explore data and ideas flexibly in the cloud
- Tools: R, RStudio, Jupyter, Python, EMR, Spark, Shiny Server, SageMaker
- Emphasis on flexibility and compatibility with production environment
- Example: Exploratory analysis of text documents in S3.


