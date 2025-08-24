#!/usr/bin/env bash
set -euo pipefail

## Generate a random cluster id
CLUSTER_ID=$(openssl rand -base64 16 | tr '+/' '-_' | tr -d '=' | cut -c1-22)
echo "CLUSTER_ID=$CLUSTER_ID"
