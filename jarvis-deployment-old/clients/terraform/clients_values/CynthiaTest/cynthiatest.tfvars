env = "dev"
region  = "us-east-1"
application_name  = "cynthiatest-jarvis"
availability_zones=["us-east-1a", "us-east-1b"]
capacity_type = "ON_DEMAND"
cluster_version = "1.33"
kms_key_owners = ["arn:aws:iam::891377081281:role/Ascending-administrator-role"]
eks_admin_user_arn = "arn:aws:iam::891377081281:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_2721c90616a1bc37"
eks_EBS_CSI_DriverRole= "arn:aws:iam::891377081281:role/AmazonEKS_EBS_CSI_DriverRole"
eks_cloudwatch_role_arn = "arn:aws:iam::891377081281:role/AmazonEKS_Observability_Role"
jarvis_values_file = "clients_values/CynthiaTest/cynthiatest_values.yaml"
helm_chart_version = "0.1.5"
jarvis_domain_name = "cynthiatest.ascendingdc.com"
cloudfront_alb = "k8s-group-48cab6c848-1157498366.us-east-1.elb.amazonaws.com"
cloudfront_cert_arn = "arn:aws:acm:us-east-1:891377081281:certificate/7ae6387e-e0b4-44b5-8a78-7b9c2cd00881"



      