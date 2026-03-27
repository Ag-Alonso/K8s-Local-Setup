# ConfigMaps & Secrets

## The Problem

Hardcoding configuration (database URLs, feature flags, credentials) into container images means rebuilding the image every time a value changes. Kubernetes solves this with **ConfigMaps** and **Secrets**.

## ConfigMaps

A **ConfigMap** stores non-sensitive configuration as key-value pairs. It can be consumed as environment variables or mounted as files.

### Creating a ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  # Simple key-value pairs
  APP_ENV: "production"
  LOG_LEVEL: "info"
  MAX_RETRIES: "3"

  # Multi-line file content
  nginx.conf: |
    server {
      listen 80;
      location / {
        root /usr/share/nginx/html;
      }
    }
```

### Using ConfigMaps as Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
    - name: app
      image: my-app:1.0
      env:
        # Single key
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_ENV
      envFrom:
        # All keys as env vars
        - configMapRef:
            name: app-config
```

### Using ConfigMaps as Mounted Files

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - name: nginx
      image: nginx:1.27
      volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
          readOnly: true
  volumes:
    - name: config-volume
      configMap:
        name: app-config
        items:
          - key: nginx.conf
            path: default.conf
```

## Secrets

A **Secret** stores sensitive data (passwords, tokens, keys). Functionally similar to ConfigMaps but with additional protections:

- Values are base64-encoded (not encrypted by default!)
- Can be encrypted at rest with EncryptionConfiguration
- Access can be restricted via RBAC
- Marked as sensitive in kubectl output

### Creating a Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
stringData:
  DB_HOST: "postgres.default.svc.cluster.local"
  DB_USER: "admin"
  DB_PASSWORD: "s3cur3p@ss"
```

### Using Secrets

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
    - name: app
      image: my-app:1.0
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_PASSWORD
      volumeMounts:
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: db-credentials
```

### Secret Types

| Type | Purpose |
|------|---------|
| `Opaque` | Arbitrary data (default) |
| `kubernetes.io/tls` | TLS certificate + key |
| `kubernetes.io/dockerconfigjson` | Docker registry credentials |
| `kubernetes.io/basic-auth` | Username + password |

## ConfigMap vs Secret

| Feature | ConfigMap | Secret |
|---------|-----------|--------|
| Purpose | Non-sensitive config | Sensitive data |
| Storage | Plain text | Base64-encoded |
| Size limit | 1 MiB | 1 MiB |
| Encryption at rest | No | Optional |
| Use for | URLs, feature flags, config files | Passwords, tokens, keys |

## How Updates Propagate

| Consumption Method | Update Behavior |
|-------------------|-----------------|
| Environment variables | **No auto-update** — requires pod restart |
| Mounted volumes | Auto-updates (kubelet sync, ~1 min delay) |

To force a restart after env var changes:

```bash
kubectl rollout restart deployment/my-app
```

## Common kubectl Commands

```bash
# Create ConfigMap from literal values
kubectl create configmap app-config --from-literal=APP_ENV=production

# Create ConfigMap from file
kubectl create configmap nginx-config --from-file=nginx.conf

# Create Secret from literal values
kubectl create secret generic db-creds --from-literal=password=s3cur3

# View ConfigMap
kubectl get configmap app-config -o yaml

# Decode a secret value
kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 -d
```

## Security Note

Kubernetes Secrets are **base64-encoded, not encrypted** by default. For production:

- Enable encryption at rest
- Use an external secret manager (Vault, AWS Secrets Manager)
- Use the External Secrets Operator to sync external secrets into K8s
- Restrict Secret access via RBAC

## Hands-On

- [Exercise 04: ConfigMaps & Secrets →](../../exercises/04-configmaps-secrets/)

## What's Next?

- [Namespaces →](06-namespaces.md)
