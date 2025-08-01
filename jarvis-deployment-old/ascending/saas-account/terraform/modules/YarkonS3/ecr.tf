resource "aws_ecr_repository" "s_webdav4" {
  name                 = "s_webdav4_${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}