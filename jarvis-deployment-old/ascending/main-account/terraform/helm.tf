resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.secret_provider_role.arn
  }
  # Add any additional configuration values as needed
}


resource "helm_release" "askcto_release" {
  name      = "askcto"
  namespace = "askcto"
  create_namespace = true
  
  repository          = "oci://897729109735.dkr.ecr.us-east-1.amazonaws.com"
  chart               = "ascending-jarvis"
  version             = "0.1.3"
  values = [
    "${file("askcto.yaml")}"
  ]

  lifecycle {
    ignore_changes = [values]
  }
}