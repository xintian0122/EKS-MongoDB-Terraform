data "aws_caller_identity" "current" {}
locals {
  bucket-a = "asc-bucket-a"
  bucket-b = "asc-bucket-b"   
}

# principal role for s3 bucket
resource "aws_iam_role" "principal_s3_role" {
  name               = "principal_s3_role"
  description = "This role allows EC2 instances to access s3 bucket."
  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "ec2.amazonaws.com"
                    ]
                }
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                },
                "Action": "sts:AssumeRole"
            },
            {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::897729109735:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/94F4957929BD24666C3008E1C389B3DE"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.us-east-1.amazonaws.com/id/94F4957929BD24666C3008E1C389B3DE:aud": "sts.amazonaws.com",
                    "oidc.eks.us-east-1.amazonaws.com/id/94F4957929BD24666C3008E1C389B3DE:sub": "system:serviceaccount:s-api:webdav4-service-account"
                }
            }
        }
        ]
    }
  )
}

# principal role policy
resource "aws_iam_policy" "main_s3_bucket_access" {
  name        = "main_s3_bucket_access_policy"
  description = "A policy to list the buckets, IAM and assume role to provide functionality for two s3 buckets"
  policy      = jsonencode(
    {
        "Version": "2012-10-17"
        "Statement": [
            {
                "Action": [
                    "iam:Get*",
                    "iam:List*"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:iam::897729109735:*",
                "Sid": "AllowServerToIterateIAMEntities"
            },
            {
                "Action": "sts:AssumeRole",
                "Effect": "Allow",
                "Resource": "*",
                "Sid": "AllowAssumeRole"
            },
            {
                "Action": "s3:*",
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::*",
                "Sid": "AllowServerToListBuckets"
            },
            {
                "Action": "secretsmanager:GetSecretValue",
                "Effect": "Allow",
                "Resource": [
                    "arn:aws:secretsmanager:us-east-1:897729109735:secret:yarkons3/env-WL0Uby"
                ],
                "Sid": "AllowServerToGetSecrets"
            }
        ],
    }
  )
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "main_s3_bucket_access" {
  role       = aws_iam_role.principal_s3_role.name
  policy_arn = aws_iam_policy.main_s3_bucket_access.arn
}

resource "aws_iam_instance_profile" "principal_s3_profile" {
  name = "principal_s3_role_profile"
  role = aws_iam_role.principal_s3_role.name
}

# user role for s3 bucket
resource "aws_iam_role" "user_s3_role" {
  name               = "user_s3_role"
  description        = "User role to access the S3 buckets"
  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "${aws_iam_role.principal_s3_role.arn}"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
  )
}

# user role policy
resource "aws_iam_policy" "user_s3_access" {
  name        = "user_s3_access"
  description = "This policy allows users to access and perform operations on two S3 buckets."
  policy      = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowServerToAccessSpecificBuckets",
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::${local.bucket-a}",
                    "arn:aws:s3:::${local.bucket-b}"
                ]
            },
            {
                "Sid": "AllowUserActionsLimitedToSpecificBuckets",
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::${local.bucket-a}/*",
                    "arn:aws:s3:::${local.bucket-b}/*"
                ]
            },
            {
                "Action"   = "s3:ListAllMyBuckets"
                "Effect"   = "Allow"
                "Resource" = "arn:aws:s3:::*"
                "Sid"      = "AllowListingAllBuckets"
            }
        ]
    }
  )
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "user_s3_access" {
  role       = aws_iam_role.user_s3_role.name
  policy_arn = aws_iam_policy.user_s3_access.arn
}

# user iam role for bucket-a
resource "aws_iam_role" "user_s3_role_a" {
  name               = "user_s3_role_a"
  description        = "User role to access the S3 bucket-a"
  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "${aws_iam_role.principal_s3_role.arn}"
                },
                "Action": "sts:AssumeRole"
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::897729109735:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_c25b44bf66cbccce"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
  )
}

# user iam role for bucket-b
resource "aws_iam_role" "user_s3_role_b" {
  name               = "user_s3_role_b"
  description        = "User role to access the S3 bucket-b"
  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "${aws_iam_role.principal_s3_role.arn}"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
  )
}

# user a role policy
resource "aws_iam_policy" "user_s3_access_a" {
  name        = "user_s3_access_a"
  description = "This policy allows users to access and perform operations on S3 bucket-a."
  policy      = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowServerToAccessSpecificBuckets",
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::${local.bucket-a}"
                ]
            },
            {
                "Sid": "AllowUserActionsLimitedToSpecificBuckets",
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::${local.bucket-a}/*"
                ]
            },
            {
                "Action"   = "s3:ListAllMyBuckets"
                "Effect"   = "Allow"
                "Resource" = "arn:aws:s3:::*"
                "Sid"      = "AllowListingAllBuckets"
            }
        ]
    }
  )
}

# attach policy to role a
resource "aws_iam_role_policy_attachment" "user_s3_access_a" {
  role       = aws_iam_role.user_s3_role_a.name
  policy_arn = aws_iam_policy.user_s3_access_a.arn
}

# user b role policy
resource "aws_iam_policy" "user_s3_access_b" {
  name        = "user_s3_access_b"
  description = "This policy allows users to access and perform operations on S3 bucket-b."
  policy      = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowServerToAccessSpecificBuckets",
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": [
                    "arn:aws:s3:::${local.bucket-b}"
                ]
            },
            {
                "Sid": "AllowUserActionsLimitedToSpecificBuckets",
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::${local.bucket-b}/*"
                ]
            },
            {
                "Action"   = "s3:ListAllMyBuckets"
                "Effect"   = "Allow"
                "Resource" = "arn:aws:s3:::*"
                "Sid"      = "AllowListingAllBuckets"
            }
        ]
    }
  )
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "user_s3_access_b" {
  role       = aws_iam_role.user_s3_role_b.name
  policy_arn = aws_iam_policy.user_s3_access_b.arn
}