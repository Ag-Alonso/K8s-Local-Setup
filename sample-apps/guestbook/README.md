# Guestbook Sample Application

This is the reference application for [Exercise 12: Capstone](../../exercises/12-capstone/).

## Architecture

```
Frontend (NGINX) → Backend (NGINX + API proxy) → Redis
```

## Components

| Component | Image | Port | Purpose |
|-----------|-------|------|---------|
| Frontend | nginx:1.27 | 80 | Serves the web UI |
| Backend | nginx:1.27 | 80 | API proxy to Redis |
| Redis | redis:7-alpine | 6379 | Data storage |

## Deployment

All manifests are in the [capstone exercise](../../exercises/12-capstone/manifests/):

```bash
kubectl apply -f ../../exercises/12-capstone/manifests/
```

## Kubernetes Resources Used

- Namespace
- Deployments (3)
- Services (3)
- ConfigMaps (3)
- PersistentVolumeClaim (1)
- Ingress (1)
- Health probes (liveness, readiness, startup)
- Rolling update strategy
- Resource requests and limits
- Standard Kubernetes labels
