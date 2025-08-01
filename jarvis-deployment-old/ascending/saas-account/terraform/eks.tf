module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = "ascending-s-api-cluster"
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns    = { resolve_conflicts = "OVERWRITE" }
    kube-proxy = { resolve_conflicts = "OVERWRITE" }
    vpc-cni    = { resolve_conflicts = "OVERWRITE" }
    amazon-cloudwatch-observability = { resolve_conflicts = "OVERWRITE",
    service_account_role_arn = "arn:aws:iam::897729109735:role/AmazonEKS_Observability_Role" }
  }

  vpc_id                   = aws_vpc.shared_vpc.id
  subnet_ids               = [aws_subnet.private_worker[0].id, aws_subnet.private_worker[1].id]
  control_plane_subnet_ids = [aws_subnet.private_cluster[0].id, aws_subnet.private_cluster[1].id]

  kms_key_owners = ["arn:aws:iam::897729109735:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_c25b44bf66cbccce",
  "arn:aws:iam::897729109735:role/GithubActionAssumeRole"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    capacity_type = var.capacity_type
  }

  eks_managed_node_groups = {

    system_node_amd = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t3.large", "t3a.large"]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size       = 1
      max_size       = 4
      desired_size   = 2
      capacity_type  = "SPOT"
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 70
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }

    system_node_ondemand = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t3.large", "t3a.large"]
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      capacity_type  = "ON_DEMAND"
      subnet_ids     = [aws_subnet.private_worker[0].id]
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }

  # # Cluster access entry
  # # To add the current caller identity as an administrator
  # enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    github = {
      principal_arn = "arn:aws:iam::897729109735:role/GithubActionAssumeRole"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    },
    admin_user = {
      principal_arn = "arn:aws:iam::897729109735:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_c25b44bf66cbccce"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.38.1-eksbuild.2"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = "arn:aws:iam::897729109735:role/AmazonEKS_EBS_CSI_DriverRole"

  configuration_values = jsonencode({
    sidecars : {
      snapshotter : {
        forceEnable : false
      }
    }
  })

}