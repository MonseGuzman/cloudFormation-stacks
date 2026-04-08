#!/bin/bash

# Variables
BUCKET_NAME="cfn-$1-s3"
STACK_NAME="$1-infra-stack"

# Functions
function deploy_template() {
    ## Create S3 bucket if it doesn't exist
    if ! aws s3 ls "s3://$BUCKET_NAME" --region $AWS_REGION 2>&1 | grep -q 'NoSuchBucket'; then
        echo "Bucket $BUCKET_NAME already exists."
    else
        echo "Creating bucket $BUCKET_NAME..."
        aws s3 mb "s3://$BUCKET_NAME" --region $AWS_REGION
    fi

    # Package the CloudFormation templates
    echo "\nPackaging CloudFormation templates..."
    aws cloudformation package \
        --s3-bucket $BUCKET_NAME \
        --template-file root-stack.yaml \
        --output-template-file packaged-template.yaml \
        --output json

    # Deploy the CloudFormation stack
    echo "\nDeploying CloudFormation stack..."
    aws cloudformation deploy \
        --template-file packaged-template.yaml \
        --stack-name $STACK_NAME \
        --capabilities CAPABILITY_NAMED_IAM
}

function cleanup() {
    echo "Deleting stack $STACK_NAME..."
    aws cloudformation delete-stack --stack-name $STACK_NAME

    echo "\nWaiting for stack deletion to complete..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

    echo "Stack deleted successfully."

    echo "\nEmptying bucket $BUCKET_NAME..."
    for key in $(aws s3 ls s3://$BUCKET_NAME --recursive); do
        echo "\nDeleting $key..."
        aws s3 rm "s3://$BUCKET_NAME/$key"
    done

    echo "\nDeleting bucket $BUCKET_NAME..."
    aws s3 rb "s3://$BUCKET_NAME" --region $AWS_REGION
}

echo "Do you want to deploy the stack (y) or delete it (n)?"
read -r response
if [[ "$response" == "y" ]]; then
    echo "Proceeding with deployment..."
    deploy_template
else
    echo "Cleanup resources."
    cleanup
fi
