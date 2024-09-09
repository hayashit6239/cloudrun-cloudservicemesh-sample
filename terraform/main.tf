terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_network_services_mesh" "test" {
  provider    = google-beta
  name        = "mesh-test"
  description = "サービスメッシュの大枠となる mesh リソース"
}

resource "google_dns_managed_zone" "mesh-zone" {
  name        = "mesh-zone"
  dns_name    = "${var.domain_name}."
  description = "サービスメッシュ構築のためのマネージドゾーン"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "projects/${var.project_id}/global/networks/${var.vpc}"
    }
  }
}

resource "google_dns_record_set" "mesh-domain-record" {
  name = "*.${var.domain_name}."
  type = "A"
  ttl  = 3600

  managed_zone = google_dns_managed_zone.mesh-zone.name

  rrdatas = ["10.0.0.1"]
}

## mesh オプションに対応していないため、gcloud コマンドでデプロイ
# resource "google_cloud_run_v2_service" "clinent" {
#   name     = "service-${var.client_name}"
#   location = var.region
#   ingress = "INGRESS_TRAFFIC_ALL"

#   template {
#     containers {
#       image = "${var.artifact_registry_path}/cloudrun/${var.client_name}:latest"
#       ports {
#         container_port = 8080
#       }
#       env {
#         name = "SERVICE_BACKEND_A_URL"
#         value = "service-backend-a"
#       }
#       env {
#         name = "SERVICE_BACKEND_B_URL"
#         value = "service-backend-b"
#       }
#       env {
#         name = "OTEL_EXPORTER_OTLP_ENDPOINT"
#         value = ""
#       }
#     }
#     vpc_access{
#       network_interfaces {
#         network = var.vpc
#         subnetwork = var.subnet
#       }
#       egress = "ALL_TRAFFIC"
#     }
#     service_account = var.service_account
#   }
# }

module "service-backend-a" {
  source = "./modules/service-backend"

  region = var.region
  artifact_registry_path = var.artifact_registry_path
  vpc = var.vpc
  subnet = var.subnet
  service_account = var.service_account
  backend_name = "backend-a"
  port = 8081
  mesh_id = google_network_services_mesh.test.id
  domain_name = var.domain_name
}

module "service-backend-b" {
  source = "./modules/service-backend"

  region = var.region
  artifact_registry_path = var.artifact_registry_path
  vpc = var.vpc
  subnet = var.subnet
  service_account = var.service_account
  backend_name = "backend-b"
  port = 8082
  mesh_id = google_network_services_mesh.test.id
  domain_name = var.domain_name
}
