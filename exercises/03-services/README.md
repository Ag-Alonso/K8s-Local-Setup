# Exercise 03: Services

**Difficulty:** Beginner | **Duration:** ~45 minutes

## Objective

Expose a Deployment using different Service types and understand Kubernetes networking basics.

## Concepts

- [Services](../../docs/04-core-concepts/04-services.md)

## Steps

### Step 1: Create the Deployment

```bash
kubectl apply -f manifests/web-deployment.yaml
```

Verify pods are running:
```bash
kubectl get pods -l app=web
```

### Step 2: Create a ClusterIP Service

```bash
kubectl apply -f manifests/web-clusterip.yaml
```

```bash
# View the service
kubectl get svc web-clusterip

# Check endpoints
kubectl get endpoints web-clusterip
```

Test connectivity from inside the cluster:
```bash
kubectl run tmp --image=busybox:1.36 --rm -it --restart=Never -- wget -qO- http://web-clusterip
```

### Step 3: Create a NodePort Service

```bash
kubectl apply -f manifests/web-nodeport.yaml
```

```bash
kubectl get svc web-nodeport
```

The service is now accessible on port 30080 on any node. In kind, access via:
```bash
# Get the node's internal IP
kubectl get nodes -o wide

# Or use port-forward as a simpler alternative
kubectl port-forward svc/web-nodeport 8080:80
# Then visit http://localhost:8080
```

### Step 4: Test DNS Resolution

```bash
kubectl run dns-test --image=busybox:1.36 --rm -it --restart=Never -- nslookup web-clusterip
```

**Expected output:**
```
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      web-clusterip
Address 1: 10.96.x.x web-clusterip.default.svc.cluster.local
```

### Step 5: Observe Load Balancing

The web app shows the pod hostname. Refresh multiple times to see different pods:

```bash
# Make multiple requests — notice the hostname changes
for i in $(seq 1 10); do
  kubectl run "tmp-$i" --image=busybox:1.36 --rm -it --restart=Never -- wget -qO- http://web-clusterip 2>/dev/null
done
```

### Step 6: Scale and Watch Endpoints Update

```bash
# Scale deployment
kubectl scale deployment/web --replicas=5

# Watch endpoints change
kubectl get endpoints web-clusterip
```

## Checkpoint

You should now understand:
- ClusterIP: internal-only service
- NodePort: external access via node ports
- Services use label selectors to find pods
- DNS names are created automatically
- Load balancing distributes traffic across pods

## Optional Challenges

1. Create a service that exposes port 8080 but targets container port 80
2. Create a headless service (clusterIP: None) and observe DNS behavior
3. Use `kubectl describe svc` to see full service details

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[04: ConfigMaps & Secrets →](../04-configmaps-secrets/)
