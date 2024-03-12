# Provider configuration 

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = "test-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "test-cluster"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}




# secret for MongoDB Credentials

resource "kubernetes_secret" "mongodb_secret" {
  metadata {
    name = "mongodb-secret"
  }

  type = "Opaque"

  data = {
    mongo-root-username = "dXNlcm5hbWU="  # base64 of 'username'
    mongo-root-password = "cGFzc3dvcmQ="  # base64 of 'password'
  }
}


#MongoDB Deployment
resource "kubernetes_deployment" "mongodb" {
  metadata {
    name = "mongodb-deployment"
    labels = {
      app = "mongodb"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }

      spec {
        container {
          name  = "mongodb"
          image = "mongo"
          port {
            container_port = 27017
          }
          env {
            name = "MONGO_INITDB_ROOT_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mongodb_secret.metadata[0].name
                key  = "mongo-root-username"
              }
            }
          }
          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mongodb_secret.metadata[0].name
                key  = "mongo-root-password"
              }
            }
          }
        }
      }
    }
  }
}


#MongoDB Service

resource "kubernetes_service" "mongodb" {
  metadata {
    name = "mongodb-service"
  }

  spec {
    selector = {
      app = "mongodb"
    }

    port {
      protocol    = "TCP"
      port        = 27017  # Service port
      target_port = 27017  # Container port
    }
  }
}
