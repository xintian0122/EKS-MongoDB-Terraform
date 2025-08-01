resource "aws_s3_bucket" "cloudfront_s3" {
  bucket = "${local.name_prefix}-bucket" 
  
}