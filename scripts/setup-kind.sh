#!/bin/bash
set -euo pipefail

# Create a kind cluster for K8s-Local-Setup exercises
# Usage: ./setup-kind.sh [cluster-name] [--multi-node]

CLUSTER_NAME="${1:-k8s-local}"
MULTI_NODE=false

for arg in "$@"; do
  case ${arg} in
    --multi-node) MULTI_NODE=true ;;
  esac
done

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Error: Docker is required. Install from https://docs.docker.com/get-docker/"; exit 1; }
command -v kind >/dev/null 2>&1 || { echo "Error: kind is required. Install from https://kind.sigs.k8s.io/docs/user/quick-start/#installation"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl is required. Install from https://kubernetes.io/docs/tasks/tools/"; exit 1; }

# Check if Docker is running
docker info >/dev/null 2>&1 || { echo "Error: Docker daemon is not running. Start Docker first."; exit 1; }

# Check if cluster already exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "Cluster '${CLUSTER_NAME}' already exists."
  echo "Delete it first with: kind delete cluster --name ${CLUSTER_NAME}"
  exit 1
fi

# Generate kind config
CONFIG_FILE=$(mktemp)
trap 'rm -f ${CONFIG_FILE}' EXIT

if [[ "${MULTI_NODE}" == "true" ]]; then
  echo "Creating multi-node cluster: ${CLUSTER_NAME} (1 control-plane + 2 workers)"
  cat > "${CONFIG_FILE}" <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${CLUSTER_NAME}
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
  - role: worker
EOF
else
  echo "Creating single-node cluster: ${CLUSTER_NAME}"
  cat > "${CONFIG_FILE}" <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${CLUSTER_NAME}
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
EOF
fi

# Create cluster
kind create cluster --config "${CONFIG_FILE}"

# Set kubectl context
kubectl cluster-info --context "kind-${CLUSTER_NAME}"

echo ""
echo "============================================"
echo "  Cluster '${CLUSTER_NAME}' is ready!"
echo "============================================"
echo ""
echo "Context: kind-${CLUSTER_NAME}"
echo "Nodes:"
kubectl get nodes
echo ""
echo "Next steps:"
echo "  1. Run ./scripts/verify-cluster.sh to verify"
echo "  2. Start with exercises/00-verify-setup/"
