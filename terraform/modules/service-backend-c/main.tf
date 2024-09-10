
resource "google_compute_region_network_endpoint_group" "backend-neg" {
  name                  = "service-${var.backend_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "asia-northeast1"
  cloud_run {
    service = "service-backend-c"
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
        service_name = "projects/${var.project_id}/global/backendServices/service-${var.backend_name}-backend-service"
      }
    }
  }

  depends_on = [
    google_compute_backend_service.backend-service
  ]
}