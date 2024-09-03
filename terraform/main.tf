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

# resource "google_cloud_run_v2_service" "backend-a" {
#   name     = "service-${var.backend_a}"
#   location = var.region
#   ingress = "INGRESS_TRAFFIC_ALL"

#   template {
#     containers {
#       image = "${var.artifact_registry_path}/cloudrun/${var.backend_a}:latest"
#       ports {
#         container_port = 8081
#       }
#       env {
#         name = "SERVICE_BACKEND_B_URL"
#         value = ""
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

# resource "google_compute_region_network_endpoint_group" "backend-a-neg" {
#   name                  = "service-${var.backend_a}-neg"
#   network_endpoint_type = "SERVERLESS"
#   region                = "asia-northeast1"
#   cloud_run {
#     service = google_cloud_run_v2_service.backend-a.name
#   }
# }

# resource "google_compute_backend_service" "backend-a-backend-service" {
#   provider              = google-beta
#   name                  = "service-${var.backend_a}-backend-service"
#   load_balancing_scheme = "INTERNAL_SELF_MANAGED"

#   backend {
#     group = google_compute_region_network_endpoint_group.backend-a-neg.id
#   }
# }

# resource "google_network_services_http_route" "backend_http_route" {
#   provider               = google-beta
#   name                   = "backend-http-route"

#   hostnames               = ["service-backend.physhp.dev"]
#   meshes = [
#     google_network_services_mesh.test.id
#   ]
#   rules {
#     matches {
#       prefix_match = "/authors"
#     }
#     action {
#       destinations {
#         service_name = google_compute_backend_service.backend-a-backend-service.id
#       }
#     }
#   }
# }