resource "aws_ecr_repository" "librechat" {
  name                 = "askcto_librechat_api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "askcto_qbusiness" {
  name                 = "askcto_qbusiness_api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}