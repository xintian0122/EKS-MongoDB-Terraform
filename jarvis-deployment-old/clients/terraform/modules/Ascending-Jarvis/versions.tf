terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.55.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
  }
}