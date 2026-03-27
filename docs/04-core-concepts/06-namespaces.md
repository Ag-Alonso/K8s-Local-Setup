# Namespaces

## What is a Namespace?

A **Namespace** is a virtual cluster within a Kubernetes cluster. Namespaces provide:

- **Isolation** — Separate teams, environments, or applications
- **Resource quotas** — Limit CPU/memory per namespace
- **RBAC scoping** — Control who can do what in each namespace
- **Organization** — Group related resources together

## Default Namespaces

Every cluster comes with these namespaces:

| Namespace | Purpose |
|-----------|---------|
| `default` | Where resources go if no namespace is specified |
| `kube-system` | Kubernetes system components (API server, CoreDNS, etc.) |
| `kube-public` | Publicly readable data (rarely used) |
| `kube-node-lease` | Node heartbeat data |

```bash
$ kubectl get namespaces
NAME              STATUS   AGE
default           Active   10m
kube-node-lease   Active   10m
kube-public       Active   10m
kube-system       Active   10m
```

## Creating a Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    env: dev
    team: backend
```

Or imperatively:

```bash
kubectl create namespace development
```

## Working with Namespaces

### Specifying Namespace in Commands

```bash
# List pods in a specific namespace
kubectl get pods -n development

# List pods in ALL namespaces
kubectl get pods -A

# Create a resource in a specific namespace
kubectl apply -f deployment.yaml -n development
```

### Specifying Namespace in YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  namespace: development      # Deployed to this namespace
spec:
  containers:
    - name: app
      image: my-app:1.0
```

### Setting a Default Namespace

Instead of typing `-n development` every time:

```bash
# Set default namespace for current context
kubectl config set-context --current --namespace=development

# Verify
kubectl config view --minify | grep namespace

# Or use kubens (if installed)
kubens development
```

## Cross-Namespace Communication

Pods in different namespaces can communicate using full DNS names:

```
<service-name>.<namespace>.svc.cluster.local
```

```bash
# From namespace "frontend", reach service "api" in namespace "backend"
curl http://api.backend.svc.cluster.local
```

Within the same namespace, just use the service name:

```bash
curl http://api    # Same namespace only
```

## Resource Quotas

Limit the total resources a namespace can consume:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    pods: "20"                     # Max 20 pods
    requests.cpu: "4"             # Total CPU requests
    requests.memory: 8Gi          # Total memory requests
    limits.cpu: "8"               # Total CPU limits
    limits.memory: 16Gi           # Total memory limits
```

## LimitRange

Set default resource limits for pods in a namespace:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: development
spec:
  limits:
    - default:                     # Default limits
        cpu: 250m
        memory: 256Mi
      defaultRequest:              # Default requests
        cpu: 100m
        memory: 128Mi
      type: Container
```

## What's Namespaced vs. Cluster-Scoped?

| Namespaced Resources | Cluster-Scoped Resources |
|---------------------|--------------------------|
| Pods, Deployments, Services | Nodes |
| ConfigMaps, Secrets | Namespaces |
| Roles, RoleBindings | ClusterRoles, ClusterRoleBindings |
| PVCs | PersistentVolumes, StorageClasses |
| Ingresses | IngressClasses |

```bash
# List all namespaced resource types
kubectl api-resources --namespaced=true

# List all cluster-scoped resource types
kubectl api-resources --namespaced=false
```

## Common Patterns

### Per-Environment Namespaces

```
default          # Don't use for real workloads
development      # Dev environment
staging          # Pre-production
production       # Production workloads
```

### Per-Team Namespaces

```
team-frontend
team-backend
team-data
```

### Per-Application Namespaces

```
app-web
app-api
app-worker
```

## Common kubectl Commands

```bash
# List namespaces
kubectl get namespaces

# Create namespace
kubectl create namespace staging

# Delete namespace (deletes ALL resources inside!)
kubectl delete namespace staging

# View resources in a namespace
kubectl get all -n development

# View resource quotas
kubectl describe resourcequota -n development
```

## Hands-On

- [Exercise 07: Namespaces →](../../exercises/07-namespaces/)

## What's Next?

- [Volumes →](07-volumes.md)
