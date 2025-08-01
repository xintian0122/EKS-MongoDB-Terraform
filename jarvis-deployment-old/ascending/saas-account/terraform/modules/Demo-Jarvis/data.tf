data "aws_iam_policy" "jarvis_policy" {
  name = "jarvis_api_policy"  
}

data "aws_s3_bucket" "cloudfront_s3" {
  bucket = "ascending-jarvis-bucket"
}
