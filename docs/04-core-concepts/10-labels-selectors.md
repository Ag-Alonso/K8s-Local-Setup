# Labels & Selectors

## What are Labels?

**Labels** are key-value pairs attached to Kubernetes objects. They are the primary mechanism for organizing, selecting, and grouping resources.

```yaml
metadata:
  labels:
    app: web-frontend
    env: production
    version: v2.1.0
    team: frontend
```

Labels are:
- **Arbitrary** — You define the keys and values
- **Non-unique** — Many objects can share the same labels
- **Queryable** — Used by selectors to filter resources

## Standard Labels

Kubernetes recommends a set of common labels:

```yaml
metadata:
  labels:
    app.kubernetes.io/name: nginx          # Application name
    app.kubernetes.io/instance: nginx-prod # Instance identifier
    app.kubernetes.io/version: "1.27"      # Application version
    app.kubernetes.io/component: frontend  # Component type
    app.kubernetes.io/part-of: webshop     # Larger application
    app.kubernetes.io/managed-by: kubectl  # Tool managing this
```

## Selectors

**Selectors** query objects based on their labels. They are used everywhere in Kubernetes.

### Equality-Based Selectors

```bash
# Match exact label value
kubectl get pods -l app=nginx
kubectl get pods -l env=production

# Not equal
kubectl get pods -l env!=production

# Multiple conditions (AND)
kubectl get pods -l app=nginx,env=production
```

### Set-Based Selectors

```bash
# In a set of values
kubectl get pods -l 'env in (production, staging)'

# Not in a set
kubectl get pods -l 'env notin (development)'

# Label exists
kubectl get pods -l app

# Label does not exist
kubectl get pods -l '!canary'
```

## Where Selectors Are Used

### Services → Pods

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-frontend        # Routes to pods with this label
    version: v2
```

### Deployments → Pods

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  selector:
    matchLabels:
      app: web-frontend      # Manages pods with this label
  template:
    metadata:
      labels:
        app: web-frontend    # Must match the selector
```

### matchExpressions (Advanced)

```yaml
spec:
  selector:
    matchLabels:
      app: web
    matchExpressions:
      - key: env
        operator: In
        values: ["production", "staging"]
      - key: canary
        operator: DoesNotExist
```

## Annotations

**Annotations** are similar to labels but for non-identifying metadata. They can't be used in selectors.

```yaml
metadata:
  annotations:
    description: "Main web frontend deployment"
    contact: "frontend-team@company.com"
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
```

Use annotations for:
- Build/release information
- Contact information
- Tool-specific configuration (Prometheus, Ingress controllers)
- Descriptions and documentation links

## Labels vs Annotations

| Feature | Labels | Annotations |
|---------|--------|-------------|
| Purpose | Identify and select | Attach metadata |
| Used in selectors | Yes | No |
| Key constraints | 63 chars, alphanumeric | 256 KB value limit |
| Used by | K8s internals + users | Tools + users |
| Example | `app: nginx` | `description: "Web server"` |

## Managing Labels

```bash
# Add a label to a resource
kubectl label pod my-pod env=production

# Update an existing label (use --overwrite)
kubectl label pod my-pod env=staging --overwrite

# Remove a label (use minus sign)
kubectl label pod my-pod env-

# Show labels in output
kubectl get pods --show-labels

# Filter by label in get
kubectl get pods -l app=nginx
kubectl get pods -l 'env in (prod,staging)'
```

## Labeling Strategy

A consistent labeling strategy makes cluster management much easier:

```yaml
# Recommended minimum labels for all resources
labels:
  app.kubernetes.io/name: my-app        # What
  app.kubernetes.io/instance: my-app-v2 # Which instance
  app.kubernetes.io/version: "2.0.0"    # What version
  app.kubernetes.io/component: api      # What role
  app.kubernetes.io/part-of: platform   # Part of what system
  app.kubernetes.io/managed-by: kubectl # How it's managed
```

## What's Next?

- [Workload Types →](11-workload-types.md)
