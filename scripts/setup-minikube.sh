#!/bin/bash
set -euo pipefail

# Create a minikube cluster for K8s-Local-Setup exercises (alternative to kind)
# Usage: ./setup-minikube.sh [profile-name] [--multi-node]

PROFILE_NAME="${1:-k8s-local}"
MULTI_NODE=false

for arg in "$@"; do
  case ${arg} in
    --multi-node) MULTI_NODE=true ;;
  esac
done

command -v docker >/dev/null 2>&1 || { echo "Error: Docker is required."; exit 1; }
command -v minikube >/dev/null 2>&1 || { echo "Error: minikube is required. Install from https://minikube.sigs.k8s.io/docs/start/"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is required."; exit 1; }
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running."; exit 1; }

if minikube status -p "${PROFILE_NAME}" >/dev/null 2>&1; then
  echo "Profile '${PROFILE_NAME}' already exists."
  echo "Delete it first with: minikube delete -p ${PROFILE_NAME}"
  exit 1
fi

if [[ "${MULTI_NODE}" == "true" ]]; then
  echo "Creating multi-node minikube cluster: ${PROFILE_NAME} (3 nodes)"
  minikube start \
    -p "${PROFILE_NAME}" \
    --driver=docker \
    --nodes=3 \
    --cpus=2 \
    --memory=2048
else
  echo "Creating single-node minikube cluster: ${PROFILE_NAME}"
  minikube start \
    -p "${PROFILE_NAME}" \
    --driver=docker \
    --cpus=2 \
    --memory=2048
fi

# Enable common addons
minikube addons enable metrics-server -p "${PROFILE_NAME}"
minikube addons enable ingress -p "${PROFILE_NAME}"

kubectl cluster-info

echo ""
echo "============================================"
echo "  minikube cluster '${PROFILE_NAME}' is ready!"
echo "============================================"
echo ""
echo "Nodes:"
kubectl get nodes
echo ""
echo "Enabled addons: metrics-server, ingress"
echo ""
echo "Useful commands:"
echo "  minikube dashboard -p ${PROFILE_NAME}  # Web UI"
echo "  minikube tunnel -p ${PROFILE_NAME}      # LoadBalancer support"
