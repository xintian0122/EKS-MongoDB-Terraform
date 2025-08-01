resource "aws_s3_bucket" "cloudfront_s3" {
  bucket = "${var.app_name}-bucket" 
  
}

# S3 Bucket Policy allowing CloudFront access
resource "aws_s3_bucket_policy" "cloudfront_access_policy" {
  bucket = aws_s3_bucket.cloudfront_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.cloudfront_s3.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution[0].arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.s3_distribution]
}
