resource "aws_ecr_repository" "S-api" {
  name                 = "s_api_backend_${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}