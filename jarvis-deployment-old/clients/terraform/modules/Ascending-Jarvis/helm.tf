resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "external-secrets"
  create_namespace = true
  version    = "v0.17.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.secret_provider_role.arn
  }
  # Add any additional configuration values as needed
}

resource "helm_release" "jarvis_release" {
  count = var.jarvis_domain_name == "" ? 0 : 1  # Only deploy if domain name is provided
  name      = "jarvis"
  namespace = "jarvis"
  create_namespace = true

  timeout = 1200
  
  repository          = "oci://897729109735.dkr.ecr.us-east-1.amazonaws.com"
  chart               = "ascending-jarvis"
  version             = var.helm_chart_version
  values = [
    "${file(var.values_file)}",
  ] 

  lifecycle {
    ignore_changes = [values]
  }
}

