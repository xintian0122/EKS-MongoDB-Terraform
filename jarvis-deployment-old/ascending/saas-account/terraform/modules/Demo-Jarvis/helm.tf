
resource "helm_release" "demo_jarvis_release" {
  name      = "jarvis-demo"
  namespace = "jarvis-demo"
  create_namespace = true
  
  repository          = "oci://897729109735.dkr.ecr.us-east-1.amazonaws.com"
  chart               = "ascending-jarvis"
  version             = "0.1.4"
  values = [
    "${file("demo-values.yaml")}"
  ] 
  lifecycle {
    ignore_changes = [values]
  }
}

