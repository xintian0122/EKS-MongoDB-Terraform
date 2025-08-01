#!/bin/bash

# Frontend Deployment Script
# Converts GitHub Actions workflow to shell script
# Usage: ./deploy-frontend.sh [ENVIRONMENT] [REGION] [S3_BUCKET_NAME] [CLOUDFRONT_DISTRIBUTION_ID]

set -e  # Exit on any error

# Function to display usage
usage() {
    echo "Usage: $0 <environment> <region> <s3_bucket_name> <cloudfront_distribution_id>"
    echo ""
    echo "Parameters:"
    echo "  environment                - Environment to deploy to (dev, demo)"
    echo "  region                     - AWS Region (e.g., us-east-1)"
    echo "  s3_bucket_name             - S3 bucket name for deployment"
    echo "  cloudfront_distribution_id - CloudFront distribution ID"
    echo ""
    echo "Environment Variables Required:"
    echo "  AWS_DEPLOY_ROLE_ARN        - IAM role ARN for deployment (optional)"
    exit 1
}

# Check if correct number of arguments provided
if [ $# -ne 4 ]; then
    echo "Error: Incorrect number of arguments"
    usage
fi

# Parse command line arguments
ENVIRONMENT="$1"
REGION="$2"
S3_BUCKET_NAME="$3"
CLOUDFRONT_DISTRIBUTION_ID="$4"

# Validate environment parameter
case "$ENVIRONMENT" in
    "dev"|"demo")
        echo "✓ Environment: $ENVIRONMENT"
        ;;
    *)
        echo "Error: Invalid environment '$ENVIRONMENT'"
        echo "Valid options: dev, demo"
        exit 1
        ;;
esac

echo "✓ Region: $REGION"
echo "✓ S3 Bucket: $S3_BUCKET_NAME"
echo "✓ CloudFront Distribution ID: $CLOUDFRONT_DISTRIBUTION_ID"
echo ""

echo "📋 Deployment Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   Region: $REGION"
echo "   S3 Bucket: $S3_BUCKET_NAME"
echo "   CloudFront Distribution ID: $CLOUDFRONT_DISTRIBUTION_ID"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed or not in PATH"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed or not in PATH"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed or not in PATH"
    exit 1
fi

echo "📦 Installing dependencies..."
npm ci
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies"
    exit 1
fi

echo "✓ Dependencies installed"

echo "🏗️  Building client..."
npm run frontend
if [ $? -ne 0 ]; then
    echo "Error: Failed to build client"
    exit 1
fi

echo "✓ Client built successfully"

echo "🚀 Deploying to S3..."
echo "   Deploying to S3 bucket: s3://$S3_BUCKET_NAME/$ENVIRONMENT/"

# Check if client/dist directory exists
if [ ! -d "client/dist" ]; then
    echo "Error: client/dist directory not found. Make sure the build was successful."
    exit 1
fi

aws s3 sync client/dist/ s3://$S3_BUCKET_NAME/$ENVIRONMENT/ --delete
if [ $? -ne 0 ]; then
    echo "Error: Failed to deploy to S3"
    exit 1
fi

echo "✓ Successfully deployed to S3"

echo "🔄 Invalidating CloudFront distribution..."

echo "   Invalidating CloudFront distribution: $CLOUDFRONT_DISTRIBUTION_ID"
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
if [ $? -ne 0 ]; then
    echo "Error: Failed to invalidate CloudFront distribution"
    exit 1
fi

echo "✅ Deployment completed successfully!"
echo ""
echo "Summary:"
echo "  Environment: $ENVIRONMENT"
echo "  S3 Bucket: s3://$S3_BUCKET_NAME/$ENVIRONMENT/"
echo "  CloudFront Distribution: $CLOUDFRONT_DISTRIBUTION_ID"