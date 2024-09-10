terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.2.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.2.0"
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
  description = "サービスメッシュ情報のキーとなる mesh リソース"
}

resource "google_compute_network" "mesh-vpc" {
  name = "mesh-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mesh-subnet" {
  name          = "mesh-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.mesh-vpc.id
}

resource "google_dns_managed_zone" "mesh-zone" {
  name        = "mesh-zone"
  dns_name    = "${var.domain_name}."
  description = "サービスメッシュ構築のためのマネージドゾーン"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.mesh-vpc.id
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

module "service-backend-a" {
  source = "./modules/service-backend"

  region = var.region
  artifact_registry_path = var.artifact_registry_path
  vpc = google_compute_network.mesh-vpc.name
  subnet = google_compute_subnetwork.mesh-subnet.name
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
  vpc = google_compute_network.mesh-vpc.name
  subnet = google_compute_subnetwork.mesh-subnet.name
  service_account = var.service_account
  backend_name = "backend-b"
  port = 8082
  mesh_id = google_network_services_mesh.test.id
  domain_name = var.domain_name
}

# module "service-backend-c" {
#   source = "./modules/service-backend-c"

#   project_id = var.project_id
#   backend_name = "backend-c"
#   mesh_id = google_network_services_mesh.test.id
#   domain_name = var.domain_name
# }

##########################################
### クライアント用の Cloud Run サービス
### 2024.09.10 時点でデプロイがうまくいなかった
##########################################
# resource "google_cloud_run_v2_service" "clinent" {
#   provider            = google-beta
#   name                = "service-client-for-backend"
#   location            = var.region
#   ingress             = "INGRESS_TRAFFIC_ALL"
#   launch_stage        = "BETA"
#   deletion_protection = false 

#   template {
#     containers {
#       image           = "${var.artifact_registry_path}/cloudrun/client-for-backend:latest"
#       ports {
#         container_port = 8080
#       }
#       env {
#         name  = "SERVICE_BACKEND_A_URL"
#         value = "http://service-backend-a.${var.domain_name}"
#         # value = "http://service-backend-c.${var.domain_name}"
#       }
#       env {
#         name  = "SERVICE_BACKEND_B_URL"
#         value = "http://service-backend-b.${var.domain_name}"
#       }
#       env {
#         name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
#         value = ""
#       }
#     }
#     service_mesh {
#       mesh = google_network_services_mesh.test.id
#     }
#     vpc_access{
#       network_interfaces {
#         network     = google_compute_network.mesh-vpc.name
#         subnetwork  = google_compute_subnetwork.mesh-subnet.name
#       }
#       egress        = "ALL_TRAFFIC"
#     }
#     service_account = var.service_account
#   }
# }
