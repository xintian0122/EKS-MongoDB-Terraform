# IAM role for EKS pods to access Cognito
resource "aws_iam_role" "eks_backend_access" {
  name = "eks-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect : "Allow"
        Principal : {
          Federated : "arn:aws:iam::897729109735:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/94F4957929BD24666C3008E1C389B3DE"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "oidc.eks.us-east-1.amazonaws.com/id/94F4957929BD24666C3008E1C389B3DE:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-1.amazonaws.com/id/94F4957929BD24666C3008E1C389B3DE:sub" : "system:serviceaccount:s-api:backend-api-service-account"
          }
        }
      }
    ]
  })
}

# IAM policy for Cognito full access
resource "aws_iam_role_policy" "cognito_full_access" {
  name = "cognito-full-access"
  role = aws_iam_role.eks_backend_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:*",
          "cognito-identity:*",
          "cognito-sync:*"
        ]
        Resource = "*"
      }
    ]
  })
}