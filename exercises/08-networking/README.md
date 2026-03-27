# Exercise 08: Networking

**Difficulty:** Intermediate | **Duration:** ~60 minutes

## Objective

Set up Ingress routing to expose services externally with host-based and path-based routing.

## Concepts

- [Ingress & Gateway API](../../docs/04-core-concepts/08-ingress-gateway-api.md)

## Prerequisites

Install the NGINX Ingress Controller (if not already installed):

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

## Steps

### Step 1: Deploy Two Applications

```bash
kubectl apply -f manifests/apps.yaml
```

```bash
kubectl get deploy,svc
```

### Step 2: Create Path-Based Ingress

```bash
kubectl apply -f manifests/path-ingress.yaml
```

```bash
kubectl get ingress
```

### Step 3: Test Path Routing

Add to `/etc/hosts`:
```bash
echo "127.0.0.1 myapp.local" | sudo tee -a /etc/hosts
```

Test:
```bash
curl http://myapp.local/app1
curl http://myapp.local/app2
```

### Step 4: Create Host-Based Ingress

```bash
kubectl apply -f manifests/host-ingress.yaml
```

Add to `/etc/hosts`:
```bash
echo "127.0.0.1 app1.local app2.local" | sudo tee -a /etc/hosts
```

Test:
```bash
curl http://app1.local
curl http://app2.local
```

### Step 5: Inspect Ingress Details

```bash
kubectl describe ingress path-ingress
kubectl describe ingress host-ingress
```

## Checkpoint

- Ingress routes external HTTP traffic to internal services
- Path-based routing sends different paths to different services
- Host-based routing sends different domains to different services
- An Ingress Controller (NGINX) must be installed first

## Cleanup

```bash
kubectl delete -f manifests/
# Optionally remove /etc/hosts entries
```

## Next Exercise

[09: Health Checks →](../09-health-checks/)
