#>>>>>>----------------------HOST----------------------------------------------

#>>> HOST-APP-NETWORK
resource "google_compute_network" "ilb_network" {
  name                    = "kaer-seren-network"
  auto_create_subnetworks = false
  project = var.project
}
#>>> HOST-APP-SUBNET
resource "google_compute_subnetwork" "ilb_subnet" {
  name          = "kaer-seren-main"
  ip_cidr_range = "10.132.32.0/24"
  region        = "europe-central2"
  network       = google_compute_network.ilb_network.id
  purpose = "PRIVATE"
  private_ip_google_access = true
}
#>>>

#>>>>>>------------------------PROXY-------------------------------------------

#>>> FOWARDING-RULE-PROXY
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "proximity"
  ip_cidr_range = "10.133.2.0/24"
  region        = "europe-central2"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.ilb_network.id
}
#>>> SERVICE-ATTATCHMENT-PROXY
resource "google_compute_subnetwork" "proxy_subnet_2" {
  name          = "proximity-2-u"
  ip_cidr_range = "10.136.2.0/24"
  region        = "europe-central2"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  role          = "ACTIVE"
  network       = google_compute_network.ilb_network.id
}
#>>>

#>>>>>>---------------------CLIENT---------------------------------------------

#>>> CLIENT-NETWORK
resource "google_compute_network" "client" {
  name                    = "kaer-seren-outpost"
  auto_create_subnetworks = false
  project = var.project
}
#>>> LOCAL-CLIENT-SUBNET
resource "google_compute_subnetwork" "test_subnet2" {
  name          = "griffin-school-subnet"
  project       = var.project
  ip_cidr_range = "10.176.76.0/24"
  region        = "europe-central2"
  role          = "ACTIVE"
  network       = google_compute_network.client.id
  private_ip_google_access = true
}
#>>> REMOTE-CLIENT-SUBNET
resource "google_compute_subnetwork" "test_subnet3" {
  name          = "griffin-school-outpost"
  project       = var.project
  ip_cidr_range = "10.176.36.0/24"
  region        = "europe-north1"
  role          = "ACTIVE"
  network       = google_compute_network.client.id
  private_ip_google_access = true
}
