provider "aws" {
  region = "us-east-1"
}

data "aws_ecr_authorization_token" "token" {
  registry_id = "897729109735"
}


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }

  registry {
    url      = "oci://897729109735.dkr.ecr.us-east-1.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}