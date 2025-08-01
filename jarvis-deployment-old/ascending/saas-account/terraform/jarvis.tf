module "jarvis" {
  source                     = "./modules/Ascending-Jarvis"
  region                     = "us-east-1"
  vpc_id                     = aws_vpc.shared_vpc.id
  private_rds_subnet_ids     = [aws_subnet.private_worker[0].id, aws_subnet.private_worker[1].id]
  app_name                   = "jarvis"
  cloudfront_alb             = "k8s-group-22940d3b9b-940547563.us-east-1.elb.amazonaws.com"
  cloudfront_cert_arn        = "arn:aws:acm:us-east-1:897729109735:certificate/718b77c4-6dda-4d08-bdfb-e0b23e485c92"
  eks_node_security_group_id = module.eks.node_security_group_id
  env                        = "dev"
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  eks_oidc_provider          = module.eks.oidc_provider
  jarvis_domain_name         = "jarvis.ascendingdc.com"

}