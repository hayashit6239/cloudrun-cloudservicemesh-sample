resource "google_cloud_run_v2_service" "backend" {
  name     = "service-${var.backend_name}"
  location = var.region
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "${var.artifact_registry_path}/cloudrun/${var.backend_name}:latest"
      ports {
        container_port = var.port
      }
      env {
        name = "SERVICE_BACKEND_B_URL"
        value = "http://service-${var.backend_name}.${domain_name}"
      }
      env {
        name = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = ""
      }
    }
    vpc_access{
      network_interfaces {
        network = var.vpc
        subnetwork = var.subnet
      }
      egress = "ALL_TRAFFIC"
    }
    service_account = var.service_account
  }
}

resource "google_compute_region_network_endpoint_group" "backend-neg" {
  name                  = "service-${var.backend_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "asia-northeast1"
  cloud_run {
    service = google_cloud_run_v2_service.backend.name
  }
}

resource "google_compute_backend_service" "backend-service" {
  provider              = google-beta
  name                  = "service-${var.backend_name}-backend-service"
  load_balancing_scheme = "INTERNAL_SELF_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.backend-neg.id
  }
}

resource "google_network_services_http_route" "backend_http_route" {
  provider               = google-beta
  name                   = "service-${var.backend_name}-http-route"

  hostnames              = ["service-${var.backend_name}.${var.domain_name}"]
  meshes = [
    var.mesh_id
  ]
  rules {
    action {
      destinations {
        service_name = google_compute_backend_service.backend-service.id
      }
    }
  }
}