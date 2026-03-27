# Exercise 07: Namespaces

**Difficulty:** Intermediate | **Duration:** ~30 minutes

## Objective

Create namespaces, deploy resources into them, and understand namespace isolation.

## Concepts

- [Namespaces](../../docs/04-core-concepts/06-namespaces.md)

## Steps

### Step 1: Create Namespaces

```bash
kubectl apply -f manifests/namespaces.yaml
```

```bash
kubectl get namespaces
```

### Step 2: Deploy to Specific Namespaces

```bash
kubectl apply -f manifests/dev-deployment.yaml
kubectl apply -f manifests/staging-deployment.yaml
```

```bash
# Pods only visible in their namespace
kubectl get pods -n development
kubectl get pods -n staging
kubectl get pods -n default    # Nothing here
```

### Step 3: Test Cross-Namespace DNS

```bash
# Create a service in development
kubectl apply -f manifests/dev-service.yaml

# Test from within staging namespace
kubectl run dns-test -n staging --image=busybox:1.36 --rm -it --restart=Never -- \
  wget -qO- http://web.development.svc.cluster.local
```

### Step 4: Set Default Namespace

```bash
kubectl config set-context --current --namespace=development
kubectl get pods    # Now shows development pods by default

# Reset to default
kubectl config set-context --current --namespace=default
```

### Step 5: Apply a ResourceQuota

```bash
kubectl apply -f manifests/dev-quota.yaml
kubectl describe resourcequota -n development
```

Try exceeding the quota:
```bash
kubectl scale deployment/web-dev -n development --replicas=50
kubectl get events -n development | tail -5
```

## Checkpoint

- Namespaces isolate resources logically
- Cross-namespace communication uses full DNS names
- ResourceQuotas limit resource consumption per namespace
- Use `-n` flag or set default namespace

## Cleanup

```bash
kubectl delete namespace development staging
```

## Next Exercise

[08: Networking →](../08-networking/)
