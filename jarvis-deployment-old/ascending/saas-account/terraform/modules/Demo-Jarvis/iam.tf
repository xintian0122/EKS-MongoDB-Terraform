

resource "aws_iam_policy" "jarvis_api_policy" {
  name        = "${local.name_prefix}_policy"
  description = "Policy for APP ${local.name_prefix} to access AWS resources"

  policy = jsonencode(
            {
            "Version": "2012-10-17",
            "Statement": [
    
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
            ]
        })
}

resource "aws_iam_role_policy_attachment" "jarvis_attachment" {
  role       = "jarvis-api-role"
  policy_arn = aws_iam_policy.jarvis_api_policy.arn
}