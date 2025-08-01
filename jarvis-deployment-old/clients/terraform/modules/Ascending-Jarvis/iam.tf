
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
          Federated = "${var.eks_oidc_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider}:sub" = "system:serviceaccount:secrets-store-csi:aws-secrets-provider-sa"
            "${var.eks_oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "${var.app_name}"
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
        Resource = [
                    "${aws_secretsmanager_secret.jarvis_secret.id}",
                    ]  # Consider restricting to specific secrets
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secret_provider_attachment" {
  role       = aws_iam_role.secret_provider_role.name
  policy_arn = aws_iam_policy.secret_provider_policy.arn
}


resource "aws_iam_role" "jarvis_role" {
  name = "jarvis-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "${var.eks_oidc_provider_arn}"
        }
        Condition = {
          StringLike = {
            "${var.eks_oidc_provider}:sub" = "system:serviceaccount:*:jarvis-service-account"
            "${var.eks_oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Application = "${var.app_name}"
    Terraform   = "true"
  }
}

resource "aws_iam_policy" "jarvis_api_policy" {
  name        = "jarvis_api_policy"
  description = "Policy for Jarvis API to access AWS resources"

  policy = jsonencode(
            {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:*"
                    ],
                    "Resource": [
                        "${aws_s3_bucket.cloudfront_s3.arn}",
                        "${aws_s3_bucket.cloudfront_s3.arn}/*"
                    ]
                },
                {
                    "Sid": "s3",
                    "Effect": "Allow",
                    "Action": [
                        "s3:ListAllMyBuckets"
                    ],
                    "Resource": [
                        "*"
                    ]
                },
                {
                    "Sid": "secretsmanager",
                    "Effect": "Allow",
                    "Action": [
                        "secretsmanager:*"
                    ],
                    "Resource": [
                        "${aws_secretsmanager_secret.jarvis_secret.id}"
                    ]
                },
                {
                    "Sid": "bedrock",
                    "Effect": "Allow",
                    "Action": [
                        "bedrock:*"
                    ],
                    "Resource": [
                        "*"
                    ]
                }
            ]
        })
}

resource "aws_iam_role_policy_attachment" "jarvis_attachment" {
  role       = aws_iam_role.jarvis_role.name
  policy_arn = aws_iam_policy.jarvis_api_policy.arn
}