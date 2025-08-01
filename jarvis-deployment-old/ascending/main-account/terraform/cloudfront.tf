resource "aws_cloudfront_origin_access_control" "askcto_s3" {
  name                              = "ascending-askcto-frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_s3_bucket" "askcto_s3" {
  bucket = "ascending-askcto-frontend"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = data.aws_s3_bucket.askcto_s3.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.askcto_s3.id
    origin_id                = "ascending-askcto-frontend.s3.us-east-1.amazonaws.com"
    origin_path              = "/${var.env}"
  }

  origin {
    domain_name = "askcto-alb-1825123480.us-east-1.elb.amazonaws.com"
    origin_id   = "askcto-alb-1825123480.us-east-1.elb.amazonaws.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  comment             = "askcto frontend distribution by terraform"
  default_root_object = "index.html"

  aliases = ["cto.ascendingdc.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ascending-askcto-frontend.s3.us-east-1.amazonaws.com"
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"


    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern             = "/api/*"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = "askcto-alb-1825123480.us-east-1.elb.amazonaws.com"
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern             = "/oauth/*"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = "askcto-alb-1825123480.us-east-1.elb.amazonaws.com"
    cache_policy_id          = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"

    viewer_protocol_policy = "redirect-to-https"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:595312265488:certificate/00cc2fcb-7f4d-4a7c-850e-4a7038c18602"
    ssl_support_method  = "sni-only"
  }
}