#!/bin/bash

# Define variables
LOKI_SERVER_IP="<LOKI_SERVER_IP>"
# go to figure out the latest version: 
# https://github.com/grafana/loki/releases
PROMTAIL_VERSION="v3.3.0"
PROMTAIL_BINARY="promtail-linux-amd64"
PROMTAIL_ZIP="${PROMTAIL_BINARY}.zip"
PROMTAIL_CONFIG_FILE="promtail-config.yaml"

PROMTAIL_JOB_NAME="nginx"
PROMTAIL_TARGETS="localhost"
PROMTAIL_LABELS_JOB="nginx"
PROMTAIL_LABELS_PATH="/var/log/nginx/*.log"

# Update system packages
echo "Updating system packages..."
sudo apt-get update -y

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt-get install -y wget unzip

# Download Promtail
echo "Downloading Promtail version ${PROMTAIL_VERSION}..."
wget "https://github.com/grafana/loki/releases/download/${PROMTAIL_VERSION}/${PROMTAIL_ZIP}"

# Unzip Promtail binary
echo "Unzipping Promtail binary..."
unzip ${PROMTAIL_ZIP}

# Move the binary to /usr/local/bin
echo "Moving Promtail binary to /usr/local/bin..."
sudo mv ${PROMTAIL_BINARY} /usr/local/bin/promtail

# Create Promtail configuration file
echo "Creating Promtail configuration file..."

cat <<EOF > ${PROMTAIL_CONFIG_FILE}
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://${LOKI_SERVER_IP}:3100/loki/api/v1/push

scrape_configs:
  - job_name: ${PROMTAIL_JOB_NAME}
    static_configs:
      - targets:
          - ${PROMTAIL_TARGETS}
        labels:
          job: ${PROMTAIL_LABELS_JOB}
          __path__: ${PROMTAIL_LABELS_PATH}
EOF

# Start Promtail with nohup
echo "Starting Promtail using nohup..."
nohup promtail -config.file=${PROMTAIL_CONFIG_FILE} &> /dev/null &

# Confirm installation and start
echo "Promtail installation and configuration complete."
echo "Promtail is now running in the background and collecting logs from Nginx."
