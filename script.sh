#!/bin/bash
# Update package list
sudo apt-get update
# Install Git
sudo apt-get install -y git
# Install Docker
sudo apt-get install -y docker.io
# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker
# Install Docker Compose
sudo apt-get install -y docker-compose
#Login to GCP
gcloud auth configure-docker gcr.io --quiet
# Pull the image from GCR, use your images pull command generated through the console.
docker pull \
    europe-central2-docker.pkg.dev/pooper-scooper/run-gmp/red-head:v2
# Run the pulled image with Docker
docker run -d --name my-container -p 80:5000 europe-central2-docker.pkg.dev/pooper-scooper/run-gmp/red-head:v2