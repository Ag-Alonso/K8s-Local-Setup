# Exercise 12: Capstone — Guestbook Application

**Difficulty:** Advanced | **Duration:** ~120 minutes

## Objective

Deploy a complete multi-service application that combines all concepts learned throughout this guide: Deployments, Services, ConfigMaps, Secrets, Persistent Storage, Ingress, Health Checks, and Namespaces.

## Architecture

```
Client → Ingress → Frontend Service → Frontend Pods
                                          ↓
                   Backend Service → Backend Pods
                                          ↓
                   Redis Service   → Redis Pod (+ PVC)
```

The Guestbook application has three components:
1. **Frontend** — NGINX serving a static page
2. **Backend** — Simple API that stores/retrieves messages
3. **Redis** — Data store for messages

## Steps

### Step 1: Create the Namespace

```bash
kubectl apply -f manifests/namespace.yaml
```

### Step 2: Deploy Redis (with Persistent Storage)

```bash
kubectl apply -f manifests/redis.yaml
```

Verify:
```bash
kubectl get pods,svc,pvc -n guestbook
```

### Step 3: Deploy the Backend

```bash
kubectl apply -f manifests/backend.yaml
```

Test the backend:
```bash
kubectl port-forward -n guestbook svc/backend 8081:80 &
curl http://localhost:8081/healthz
kill %1
```

### Step 4: Deploy the Frontend

```bash
kubectl apply -f manifests/frontend.yaml
```

### Step 5: Create the Ingress

```bash
kubectl apply -f manifests/ingress.yaml
```

Add to `/etc/hosts`:
```bash
echo "127.0.0.1 guestbook.local" | sudo tee -a /etc/hosts
```

Test:
```bash
curl http://guestbook.local
```

### Step 6: Verify Everything Works

```bash
# All resources in the guestbook namespace
kubectl get all -n guestbook

# Check all pods are healthy
kubectl get pods -n guestbook

# Check services
kubectl get svc -n guestbook

# Check ingress
kubectl get ingress -n guestbook
```

### Step 7: Test the Application

```bash
# Access the frontend
curl http://guestbook.local

# Or use port-forward
kubectl port-forward -n guestbook svc/frontend 8080:80
# Visit http://localhost:8080
```

### Step 8: Scale the Frontend

```bash
kubectl scale deployment/frontend -n guestbook --replicas=5
kubectl get pods -n guestbook -l app=frontend
```

### Step 9: Perform a Rolling Update

```bash
kubectl set image deployment/frontend -n guestbook frontend=nginx:1.28
kubectl rollout status deployment/frontend -n guestbook
```

### Step 10: Verify Data Persistence

```bash
# Delete the Redis pod (it will be recreated by the Deployment)
kubectl delete pod -n guestbook -l app=redis

# Wait for it to come back
kubectl get pods -n guestbook -l app=redis -w

# Data should persist thanks to the PVC
```

## Checkpoint

You've successfully deployed a multi-service application with:
- Namespace isolation
- Persistent storage (Redis)
- ConfigMaps for configuration
- Health checks on all components
- Ingress for external access
- Rolling updates
- Scaling

## Optional Challenges

1. Add resource quotas to the guestbook namespace
2. Create a NetworkPolicy that only allows frontend → backend → redis traffic
3. Add a CronJob that periodically backs up Redis data
4. Implement TLS on the Ingress

## Cleanup

```bash
kubectl delete namespace guestbook
```

## Congratulations!

You've completed all exercises in the K8s-Local-Setup guide. You now have a solid foundation in Kubernetes fundamentals. Next steps to continue your journey:

- **Helm** — Package manager for Kubernetes
- **Kustomize** — Template-free configuration management
- **GitOps** — ArgoCD or Flux for declarative deployments
- **Observability** — Prometheus, Grafana, Loki for monitoring
- **Service Mesh** — Istio or Linkerd for advanced networking
- **CKA/CKAD** — Kubernetes certifications
