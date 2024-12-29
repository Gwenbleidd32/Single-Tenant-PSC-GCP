#>>>>>>----------------------------HOST----------------------------------------

#>>> HEALTH-CHECK
resource "google_compute_firewall" "fw_iap" {
  name          = "health-is-your-wealth"
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports = ["80"]
  }
}
#>>> PEER-INVATATION
resource "google_compute_firewall" "fw_ilb_to_backends" {
  name          = "private-route"
  direction     = "INGRESS"
  network       = google_compute_network.ilb_network.id
  source_ranges = ["10.176.76.0/24","10.133.2.0/24","10.176.32.0/24","10.136.2.0/24","10.176.36.0/24"] 
  target_tags   = ["http-server"] #>>> Proxy included for service attatchment and the fowarding rule
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
} 
#>>> SSH-RULE
resource "google_compute_firewall" "host_ssh" {
  name          = "host-ssh"
  network       = google_compute_network.ilb_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
#>>> RDP-RULE
resource "google_compute_firewall" "host_rdp" {
  name          = "host-rdp"
  network       = google_compute_network.ilb_network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  } 
}
#>>>

#>>>>>>----------------------------CLIENT--------------------------------------

#>>> SSH-RULE
resource "google_compute_firewall" "client_ssh" {
  name          = "rpoop2"
  network       = google_compute_network.client.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
#>>> RDP-RULE
resource "google_compute_firewall" "client_rdp" {
  name          = "l7-ilb-fw-allow-iap-hc"
  direction     = "INGRESS"
  network       = google_compute_network.client.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["3389"]
  }
}
#>>>          