# AWS CloudFormation - Nested Stacks

This repository contains a set of AWS CloudFormation templates designed to practice and demonstrate the implementation of **Nested Stacks**. The goal is to build a modular, reusable, and organized infrastructure by decoupling components into specialized templates.

## 🤗 Project Overview

Using Nested Stacks allows for better management of complex architectures. In this little project, a "Parent" (or "Root") stack is used to orchestrate the deployment of multiple "Child" stacks, passing parameters between them and centralizing the lifecycle of the entire infrastructure.

### Current Architecture

The project follows a modular structure:
- **Root Stack:** The main entry point that defines `AWS::CloudFormation::Stack` resources.
- **Child Stacks:** Individual templates for specific resources (e.g., Networking, Security Groups, EC2 instances, or S3 Buckets).

## 📁 Repository Structure

```text
.
├── components/              # Directory for child templates
│   └── cloudwatch.yaml      # Compute resources (EC2, ASG, etc.)
│   ├── ec2.yaml             # Compute layer (EC2, SSH key, SG rules)
│   ├── loadbalancer.yaml    # Traffic layer (LB, WAF)
│   └── network.yaml         # Compute resources (EC2, ASG, etc.)
├── root-stack.yaml          # Main template to deploy all nested stacks
└── parameters/              # (Optional) Environment-specific configurations
```

### 🫨 Prerequisites
- An AWS Account.
- AWS CLI configured with 🫵🏼 appropriate permissions.
- _(Optional)_ An S3 Bucket to host the child templates (CloudFormation requires nested templates to be accessible via an S3 URL or file path during deployment).

### 🏃🏻‍♀️ How to Deploy
If you previously save those template in S3 bucket, upload child templates to S3: _Nested stacks require the TemplateURL to point to a valid location._

```bash
aws s3 cp components/ s3://your-bucket-name/cloudformation/components/ --recursive
```

Deploy the Root Stack:
```bash
aws cloudformation create-stack \
  --stack-name nestedPractice \
  --template-body file://root-stack.yaml \
  --parameters ParameterKey=BucketURL,ParameterValue=[https://your-bucket-name.s3.amazonaws.com/cloudformation/](https://your-bucket-name.s3.amazonaws.com/cloudformation/) \
  --capabilities CAPABILITY_IAM
```

In the case, you do not create a S3 Bucket, you can run the `deploy-locally.sh` script.

```bash
chmod +x ./deploy-locally.sh
./deploy-locally.sh
```