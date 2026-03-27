# Exercises

Hands-on exercises to practice Kubernetes concepts. Work through them in order — each builds on skills from previous exercises.

## Prerequisites

Before starting, ensure you have:
- A running Kubernetes cluster (see [Setup Guides](../docs/03-setup-guides/))
- `kubectl` configured and connected to your cluster
- Run `../scripts/verify-cluster.sh` to confirm everything works

## Exercise Progression

| # | Exercise | Difficulty | Duration | Concepts |
|---|----------|------------|----------|----------|
| 00 | [Verify Setup](00-verify-setup/) | Beginner | 15 min | kubectl, cluster info |
| 01 | [First Pod](01-first-pod/) | Beginner | 30 min | Pods, containers, logs |
| 02 | [Deployments](02-deployments/) | Beginner | 45 min | Deployments, ReplicaSets, scaling |
| 03 | [Services](03-services/) | Beginner | 45 min | ClusterIP, NodePort, DNS |
| 04 | [ConfigMaps & Secrets](04-configmaps-secrets/) | Beginner | 45 min | Configuration, env vars, mounts |
| 05 | [Persistent Storage](05-persistent-storage/) | Intermediate | 60 min | PV, PVC, StorageClass |
| 06 | [Rolling Updates](06-rolling-updates/) | Intermediate | 45 min | Update strategies, rollback |
| 07 | [Namespaces](07-namespaces/) | Intermediate | 30 min | Isolation, resource quotas |
| 08 | [Networking](08-networking/) | Intermediate | 60 min | Ingress, routing, DNS |
| 09 | [Health Checks](09-health-checks/) | Intermediate | 45 min | Liveness, readiness, startup |
| 10 | [Observability Basics](10-observability-basics/) | Intermediate | 60 min | Logs, metrics, debugging |
| 11 | [Multi-Container Pods](11-multi-container-pods/) | Intermediate | 45 min | Sidecars, init containers |
| 12 | [Capstone: Guestbook](12-capstone/) | Advanced | 120 min | Full multi-service application |

## Exercise Structure

Each exercise contains:

```
exercise-name/
├── README.md         # Instructions, objectives, steps
├── manifests/        # YAML files you'll apply
└── solution/         # Reference solutions (try first!)
```

## Tips

- **Read the entire exercise** before starting
- **Type the YAML yourself** instead of copy-pasting (builds muscle memory)
- **Validate each step** before moving to the next
- **Use `kubectl describe`** when something doesn't work
- **Check logs** with `kubectl logs` for container issues
- **Solutions are there to help** — no shame in checking them

## Cleanup

After completing exercises, clean up resources:

```bash
# Delete all resources in default namespace
kubectl delete all --all

# Or delete the entire cluster and start fresh
kind delete cluster --name k8s-local
```
