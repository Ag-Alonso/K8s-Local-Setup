#!/bin/bash
set -euo pipefail

# Verify that a Kubernetes cluster is running and healthy
# Works with kind, k3d, minikube, or any kubeconfig-configured cluster

: "${KUBECONFIG:=${HOME}/.kube/config}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
  local description="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} ${description}"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗${NC} ${description}"
    FAIL=$((FAIL + 1))
  fi
}

echo "============================================"
echo "  Kubernetes Cluster Verification"
echo "============================================"
echo ""

# Prerequisites
echo "Prerequisites:"
check "kubectl installed" command -v kubectl
check "docker running" docker info
echo ""

# Cluster connectivity
echo "Cluster Connectivity:"
check "kubectl can reach cluster" kubectl cluster-info
check "API server responding" kubectl get --raw /healthz
echo ""

# Node status
echo "Node Status:"
check "Nodes are Ready" kubectl wait --for=condition=Ready nodes --all --timeout=10s
echo ""
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
echo -e "  Nodes found: ${NODE_COUNT}"
echo ""

# Core components
echo "Core Components:"
check "kube-system pods running" kubectl get pods -n kube-system --field-selector=status.phase=Running
check "CoreDNS running" kubectl get pods -n kube-system -l k8s-app=kube-dns --field-selector=status.phase=Running
echo ""

# Basic functionality
echo "Basic Functionality:"
TEMP_NS="verify-$(date +%s)"
if kubectl create namespace "${TEMP_NS}" >/dev/null 2>&1; then
  check "Can create namespace" true

  # Test pod creation
  if kubectl run verify-pod --image=busybox --restart=Never \
    --namespace="${TEMP_NS}" --command -- sleep 5 >/dev/null 2>&1; then
    sleep 3
    check "Can create pods" kubectl get pod verify-pod -n "${TEMP_NS}"
  else
    check "Can create pods" false
  fi

  # Cleanup
  kubectl delete namespace "${TEMP_NS}" --wait=false >/dev/null 2>&1
else
  check "Can create namespace" false
fi
echo ""

# Summary
echo "============================================"
echo -e "  Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "============================================"

if [[ ${FAIL} -gt 0 ]]; then
  echo ""
  echo -e "${YELLOW}Some checks failed. See docs/03-setup-guides/troubleshooting.md${NC}"
  exit 1
fi
