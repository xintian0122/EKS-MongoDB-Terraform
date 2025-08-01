
# Create IAM role for AWS Secret Provider
resource "aws_iam_role" "secret_provider_role" {
  name = "eks-secret-provider-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:secrets-store-csi:aws-secrets-provider-sa"
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "askcto"
    Terraform   = "true"
  }
}

resource "aws_iam_policy" "secret_provider_policy" {
  name        = "eks-secret-provider-policy"
  description = "Policy for AWS Secret Provider to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "${aws_secretsmanager_secret.librechat_secret.id}" # Consider restricting to specific secrets
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secret_provider_attachment" {
  role       = aws_iam_role.secret_provider_role.name
  policy_arn = aws_iam_policy.secret_provider_policy.arn
}