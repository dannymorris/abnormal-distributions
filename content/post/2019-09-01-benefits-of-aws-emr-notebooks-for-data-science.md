---
title: Benefits of AWS EMR Notebooks for Data Science
author: Danny Morris
date: '2019-09-01'
slug: benefits-of-aws-emr-notebooks-for-data-science-teams
categories:
  - AWS
tags:
  - AWS
---

This document highlights some of the benefits of using EMR Notebooks for data science.

EMR Notebooks is an AWS-managed service that provides access to Jupyter Notebooks running on an EMR cluster with kernels for PySpark, SparkR, and Python. This tool is ideal for exploratory analysis with Python and Spark and for developing applications for big data processing. 

## 1. Minimal configuration

You can launch an EMR Notebook through the AWS Console with minimial configuration. Simply give the notebook a name, specifiy the EMR cluster (new or existing), specify the security group and role, then choose an s3 bucket to host the notebook. AWS manages the rest. 

## 2. Supports Spark, Python, and R*

By default, EMR Notebooks provide kernels for PySpark, Python, and SparkR. There is no default kernel for base R, though it is simple to install RStudio Server on the master node.

## 3. Persist data and code in S3

When an EMR cluster shuts down, everything goes with it. With EMR Notebooks, the notebooks are hosted in an S3 bucket for durability. If the cluster shuts down unexpectedly, notebooks and data in S3 are unaffected.

## 4. Multiple users sharing the same cluster

Clusters are currently able to support up to 24 active notebooks on the master node. Users can stop their notebooks to avoid counting towards the current limit. This flexible arrangement enables multiple users to leverage the EMR cluster.

## 5. Isolated notebooks

When a notebook is launched, it is completely isolated from other notebooks on the same cluster. Spark sessions in one notebook do not interfere with sessions in another. Developers have the flexibility to customize their notebook as needed.

## 6. Big data processing

EMR clusters are designed to enable big data processing using multiple machines in a cluster.

## 7. No additional charage

There is no additional charage for EMR Notebooks. Only pay for the EMR cluster.
