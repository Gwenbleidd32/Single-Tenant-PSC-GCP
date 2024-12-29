#>>>>>>--------------------------LOAD-BALANCER---------------------------------

#>>> FOWARDING-RULES
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "rule-poop-32"
  region                = "europe-central2"
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.proxify.id
  network               = google_compute_network.ilb_network.id
  subnetwork            = google_compute_subnetwork.ilb_subnet.id
  network_tier          = "PREMIUM"
  allow_global_access   = true
}
#>>> HTTP-PROXY
resource "google_compute_region_target_http_proxy" "proxify" {
  name     = "proxify"
  region   = "europe-central2" #DISABLE FOR GLOBAL RESOURCES
  url_map  = google_compute_region_url_map.cartographer.id
}
#>>> URL-MAP
resource "google_compute_region_url_map" "cartographer" {
  name            = "cartographer"
  region          = "europe-central2"
  default_service = google_compute_region_backend_service.backside_1.id
}
#>>> BACKEND-SERVICE-REGIONAL
resource "google_compute_region_backend_service" "backside_1" {
  name                  = "backbay-service"
  region                = "europe-central2"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.doctor_1.id]
  backend {
    group           = google_compute_region_instance_group_manager.mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
#>>> HEALTH-CHECK
resource "google_compute_region_health_check" "doctor_1" {
  name     = "dotore"
  region   = "europe-central2" 
  http_health_check {
    port_specification = "USE_SERVING_PORT"
    request_path = "/"#Important
  }
}
#>>>

#>>>>>>----------------------INSTANCE-TEMPLATE-AND-GROUP-----------------------

#>>> MANAGED-INSTANCE-GROUP-1
resource "google_compute_region_instance_group_manager" "mig" {
  name     = "group-beta"
  region   = "europe-central2"
  version {
    instance_template = google_compute_instance_template.instance_template.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 3

    named_port {
    name = "http"
    port = 80
  }
}
#>>> NOTE: For multi subnet distribution 2 instance groups are needed

#>>> INSTANCE-TEMPLATE-1
resource "google_compute_instance_template" "instance_template" {
  name         = "docker-stencil"
  machine_type = "e2-small"
  tags         = ["http-server"]

  network_interface {
    network    = google_compute_network.ilb_network.id
    subnetwork = google_compute_subnetwork.ilb_subnet.id
    access_config {
      # add external ip to fetch packages- Needed for Healthy Load Balancer, Does not bode well when removed. 
    }
  }
  disk {
    source_image = "projects/debian-cloud/global/images/debian-11-bullseye-v20241210"
    auto_delete  = true
    boot         = true
  }
  # install script for simple web server
  metadata = {
    startup-script = file("${path.module}/script.sh")
  }
  lifecycle {
    create_before_destroy = true
  }
}
#>>>

#>>>>>>--------------------------AUTO-SCALER-----------------------------------

resource "google_compute_region_autoscaler" "scale_1" {
  name     = "de-scaler"
  target   = google_compute_region_instance_group_manager.mig.id
  region     = "europe-central2"
  autoscaling_policy {
    max_replicas = 8
    min_replicas = 3

    cpu_utilization {
      target = 0.8  # Target 80% CPU utilization
    }
  }
}
#>>>

#>>>>>>-----------------------SERVICE-ATTATCHEMENT-----------------------------

resource "google_compute_service_attachment" "ilb_service_attachment" {
  name                  = "angsty-moss"
  region                = "europe-central2"
  connection_preference = "ACCEPT_AUTOMATIC"
  enable_proxy_protocol = false # >>> ensures client network information is passed to the backend
  nat_subnets           = [google_compute_subnetwork.proxy_subnet_2.id] # >>> Assigns IP addresses to incoming traffic from PSC using the proxy subnet
  target_service        = google_compute_forwarding_rule.google_compute_forwarding_rule.self_link
}
#>>> OUTPUTS
output "service_attachment_self_link" {
  value = google_compute_service_attachment.ilb_service_attachment.self_link
  description = "The self-link of the service attachment, used by consumers to connect."
}
output "service_attachment_self_link_custom" {
  value = "projects/${var.project}/regions/${google_compute_service_attachment.ilb_service_attachment.region}/serviceAttachments/${google_compute_service_attachment.ilb_service_attachment.name}"
}
#>>>