
resource "aws_ecr_repository" "Jarvis" {
  name                 = "${local.name_prefix}_jarvis_api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "guardrail" {
  name                 = "${local.name_prefix}_guardrail_api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "llamaIndex" {
  name                 = "${local.name_prefix}_llama_index"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}