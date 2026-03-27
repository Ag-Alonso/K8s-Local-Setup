#!/bin/bash
set -euo pipefail

# Create a k3d cluster for K8s-Local-Setup exercises (alternative to kind)
# Usage: ./setup-k3d.sh [cluster-name] [--multi-node]

CLUSTER_NAME="${1:-k8s-local}"
MULTI_NODE=false

for arg in "$@"; do
  case ${arg} in
    --multi-node) MULTI_NODE=true ;;
  esac
done

command -v docker >/dev/null 2>&1 || { echo "Error: Docker is required."; exit 1; }
command -v k3d >/dev/null 2>&1 || { echo "Error: k3d is required. Install from https://k3d.io/#installation"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is required."; exit 1; }
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running."; exit 1; }

if k3d cluster list 2>/dev/null | grep -q "${CLUSTER_NAME}"; then
  echo "Cluster '${CLUSTER_NAME}' already exists."
  echo "Delete it first with: k3d cluster delete ${CLUSTER_NAME}"
  exit 1
fi

if [[ "${MULTI_NODE}" == "true" ]]; then
  echo "Creating multi-node k3d cluster: ${CLUSTER_NAME} (1 server + 2 agents)"
  k3d cluster create "${CLUSTER_NAME}" \
    --servers 1 \
    --agents 2 \
    --port "80:80@loadbalancer" \
    --port "443:443@loadbalancer" \
    --wait
else
  echo "Creating single-node k3d cluster: ${CLUSTER_NAME}"
  k3d cluster create "${CLUSTER_NAME}" \
    --port "80:80@loadbalancer" \
    --port "443:443@loadbalancer" \
    --wait
fi

kubectl cluster-info

echo ""
echo "============================================"
echo "  k3d cluster '${CLUSTER_NAME}' is ready!"
echo "============================================"
echo ""
echo "Nodes:"
kubectl get nodes
echo ""
echo "Note: k3d uses k3s (lightweight K8s). Some features"
echo "may differ slightly from upstream Kubernetes."
