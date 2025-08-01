locals {
  env_variables = ["USERNAME","PASSWORD"]
}
resource "aws_secretsmanager_secret" "yarkons3_secret" {
  name = "yarkons3/env"  
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = aws_secretsmanager_secret.yarkons3_secret.id
  secret_string = jsonencode({
    for key in local.env_variables : key => ""
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}