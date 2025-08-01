resource "aws_s3_bucket" "bucket-a" {
  bucket = local.bucket-a

  tags = {
    Name        = "asc-bucket-a"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "bucket-a" {
  bucket = aws_s3_bucket.bucket-a.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "bucket-b" {
  bucket = local.bucket-b

  tags = {
    Name        = "asc-bucket-b"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "bucket-b" {
  bucket = aws_s3_bucket.bucket-b.id
  versioning_configuration {
    status = "Enabled"
  }
}