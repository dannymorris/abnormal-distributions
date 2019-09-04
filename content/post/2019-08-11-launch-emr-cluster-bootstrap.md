---
title: Launch an EMR Cluster with Bootstrapped Actions Using the AWS CLI
author: Danny Morris
date: '2019-08-11'
slug: launch-emr-cluster-bootstrapped-actions-using-aws-cli
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

The following AWS CLI command will launch a 5 node (1 master node and 4 worker nodes) EMR 5.25 cluster with Spark, RStudio Server, Shiny Server, sparklyr, and other aplications pre-installed and ready to use.

**bootstrap.sh**

```
aws emr create-cluster \
    --applications Name=Hadoop Name=Spark Name=JupyterHub Name=TensorFlow \
    --release-label emr-5.25.0 \
    --name "EMR 5.25 RStudio + sparklyr 2" \
    --service-role EMR_DefaultRole \
    --instance-groups InstanceGroupType=MASTER,InstanceCount=1,InstanceType=m5a.2xlarge InstanceGroupType=CORE,InstanceCount=4,InstanceType=m5a.2xlarge \
    --bootstrap-action Path=s3://aws-bigdata-blog/artifacts/aws-blog-emr-rstudio-sparklyr/rstudio_sparklyr_emr5.sh,Args=["--rstudio","--sparklyr","--rstudio-url","https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-1.2.1335-x86_64.rpm"],Name="Install RStudio" \
    --ec2-attributes InstanceProfile=EMR_EC2_DefaultRole,KeyName=$YOUR_KEY \
    --configurations '[{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"}}]' \
    --region us-east-1
```