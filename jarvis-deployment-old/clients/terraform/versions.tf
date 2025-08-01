terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}