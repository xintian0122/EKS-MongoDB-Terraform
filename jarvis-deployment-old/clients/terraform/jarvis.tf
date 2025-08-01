module "jarvis" {
  source                     = "./modules/Ascending-Jarvis"
  region                     = var.region
  vpc_id                     = aws_vpc.shared_vpc.id
  private_rds_subnet_ids     = [aws_subnet.private_worker[0].id, aws_subnet.private_worker[1].id]
  app_name                   = var.application_name
  cloudfront_alb             = var.cloudfront_alb
  cloudfront_cert_arn        = var.cloudfront_cert_arn
  eks_node_security_group_id = module.eks.node_security_group_id
  env                        = var.env
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  eks_oidc_provider          = module.eks.oidc_provider
  jarvis_domain_name         = var.jarvis_domain_name
  values_file                = var.jarvis_values_file
  helm_chart_version         = var.helm_chart_version
}
