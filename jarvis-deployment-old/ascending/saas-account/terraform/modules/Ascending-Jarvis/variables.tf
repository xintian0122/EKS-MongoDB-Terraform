###########################################################################
# Application Information
###########################################################################
variable "env" {
  type    = string
  default = "dev"
}
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "private_rds_subnet_ids" {
  type    = list(string)
  default = []
}

variable "app_name" {
  type    = string
  default = "Jarvis"
}

variable "cloudfront_alb" {
  type    = string
  default = ""
}

variable "cloudfront_cert_arn" {
  type    = string
  default = ""
}

variable "eks_node_security_group_id" {
  type    = string
  default = "" 
}

variable "eks_oidc_provider_arn" {
  type    = string
  default = ""
}
variable "eks_oidc_provider" {
  type    = string
  default = ""
}

variable "jarvis_domain_name" {
  type    = string
  default = "jarvis.ascendingdc.com"
  
}