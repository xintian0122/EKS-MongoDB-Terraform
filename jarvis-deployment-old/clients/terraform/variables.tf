###########################################################################
# Account Information
###########################################################################
variable "env" {
  type    = string
  default = "dev"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "application_name" {
  type = string
  default = "Ascending-Jarvis"
}

###########################################################################
# Network Information
###########################################################################

variable "vpc_cidr" {
  description = "cidr of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
}

variable "private_worker_subnet_cidrs" {
  description = "CIDR blocks for private worker subnets"
  type        = list(string)
  default     = ["10.0.64.0/19", "10.0.96.0/19"]
}

variable "private_cluster_subnet_cidrs" {
  description = "CIDR blocks for private cluster subnets"
  type        = list(string)
  default     = ["10.0.128.0/28", "10.0.128.16/28"]
}

###########################################################################
# Account Information
###########################################################################
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# EKS Cluster 
################################################################################

variable "capacity_type" {
  description = "spot or on demand instance for eks cluster node"
  type        = string
  default     = "SPOT"
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.31`)"
  type        = string
  default     = "1.32"
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

################################################################################
# KMS Key in EKS Module
################################################################################

variable "kms_key_description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = null
}

variable "kms_key_owners" {
  description = "A list of IAM ARNs for those who will have full key permissions (`kms:*`)"
  type        = list(string)
  default     = []
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(string)
  default     = []
}

################################################################################
# CloudWatch Log Group - EKS Module
################################################################################

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

################################################################################
# Cluster Security Group - EKS Module
################################################################################

variable "create_cluster_security_group" {
  description = "Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default"
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "Existing security group ID to be attached to the cluster"
  type        = string
  default     = ""
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created"
  type        = string
  default     = null
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "cluster_security_group_description" {
  description = "Description of the cluster security group created"
  type        = string
  default     = "EKS cluster security group"
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

################################################################################
# Node Security Group - EKS Module
################################################################################

variable "create_node_security_group" {
  description = "Determines whether to create a security group for the node groups or use the existing `node_security_group_id`"
  type        = bool
  default     = true
}

variable "node_security_group_id" {
  description = "ID of an existing security group to attach to the node groups created"
  type        = string
  default     = ""
}

variable "node_security_group_name" {
  description = "Name to use on node security group created"
  type        = string
  default     = null
}

variable "node_security_group_use_name_prefix" {
  description = "Determines whether node security group name (`node_security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "node_security_group_description" {
  description = "Description of the node security group created"
  type        = string
  default     = "EKS node shared security group"
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "node_security_group_enable_recommended_rules" {
  description = "Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic"
  type        = bool
  default     = true
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}


################################################################################
# Cluster IAM Role - EKS Module 
################################################################################

variable "create_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "eks_admin_user_arn" {
  description = "The ARN of the IAM user or role that will have admin access to the EKS cluster"
  type        = string
  default     = ""
}

variable "eks_cloudwatch_role_arn" {
  description = "The ARN of the IAM role that will be used for CloudWatch logging"
  type        = string
  default     = ""
}

variable "eks_EBS_CSI_DriverRole" {
  description = "The ARN of the IAM role that will be used for EBS CSI Driver"
  type        = string
  default     = ""
}

variable "eks_node_instance_types" {
  description = "A list of instance types to use for the EKS managed node groups. If not provided, the default instance type will be used"
  type        = list(string)
  default     = ["t3.large", "t3a.large"]
  
}


################################################################################
# Jarvis Module 
################################################################################
variable "jarvis_domain_name" {
  description = "The domain name for the Jarvis application"
  type        = string
  default     = ""
}
variable "jarvis_values_file" {
  description = "The path to the values file for the Jarvis Helm chart"
  type        = string
  default     = "clients_values/values.yaml"
}

variable "helm_chart_version" {
  type    = string
  default = "0.1.4"
  
}

variable "cloudfront_alb" {
  type    = string
  default = ""
}

variable "cloudfront_cert_arn" {
  type    = string
  default = ""
}