#>>>>>---------------------CONSUMER-APPLICATIONS-------------------------------

# >>> LOCAL-REGIONAL-SUBNETWORK
resource "google_compute_instance" "consumer_instance" {
  name         = "caranthir"
  machine_type = "e2-highmem-2"
  zone         = "europe-central2-a"

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size = 50 
      type = "pd-balanced"
    }
  }

  network_interface {
    access_config {
      // Ephemeral IP
      network_tier = "PREMIUM"
    }
    subnetwork = google_compute_subnetwork.test_subnet2.id
    stack_type  = "IPV4_ONLY"
  }

  service_account {
    email  = "876288284083-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  depends_on = [ google_compute_subnetwork.test_subnet2 ]
}
#>>>

# >>> REMOTE-REGIONAL-SUBNETWORK
resource "google_compute_instance" "consumer_instance_remote" {
  name         = "caranthir-remote"
  machine_type = "e2-highmem-2"
  zone         = "europe-north1-a"

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
      size = 50 
      type = "pd-balanced"
    }
  }

  network_interface {
    access_config {
      // Ephemeral IP
      network_tier = "PREMIUM"
    }
    subnetwork = google_compute_subnetwork.test_subnet3.id
    stack_type  = "IPV4_ONLY"
  }

  service_account {
    email  = "876288284083-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  depends_on = [ google_compute_subnetwork.test_subnet3 ]
}
#>>>
