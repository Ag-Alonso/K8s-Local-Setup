# Ingress & Gateway API

## The Problem

Services of type `ClusterIP` are only accessible inside the cluster. `NodePort` works but requires knowing node IPs and using high port numbers. For HTTP/HTTPS traffic, you need a better way to route external requests to your services.

## Ingress

An **Ingress** is an API object that manages external HTTP/HTTPS access to services. It provides:

- **Host-based routing** — Route by domain name
- **Path-based routing** — Route by URL path
- **TLS termination** — Handle HTTPS certificates
- **Single entry point** — One external IP for many services

### Ingress Controller

An Ingress resource alone does nothing. You need an **Ingress Controller** — a pod that reads Ingress rules and configures a reverse proxy (usually NGINX or Envoy).

Popular controllers:
- **NGINX Ingress Controller** — Most common, good for learning
- **Traefik** — Auto-discovery, built into k3s/k3d
- **HAProxy** — High performance
- **Envoy-based** (Contour, Emissary) — Advanced features

### Installing NGINX Ingress in kind

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for it to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

### Basic Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  ingressClassName: nginx          # Which controller to use
  rules:
    - host: myapp.local            # Domain name
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service  # Target service
                port:
                  number: 80
```

### Path-Based Routing

Route different URL paths to different services:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: myapp.local
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80
```

### Host-Based Routing

Route different domains to different services:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-host-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: api.myapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
    - host: web.myapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
```

### TLS Termination

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - myapp.local
      secretName: myapp-tls        # Secret with TLS cert/key
  rules:
    - host: myapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
```

### Path Types

| Type | Behavior |
|------|----------|
| `Prefix` | Matches URL path prefix (`/api` matches `/api/users`) |
| `Exact` | Matches exact path only (`/api` does NOT match `/api/users`) |
| `ImplementationSpecific` | Depends on IngressClass |

## Request Flow

> See the full diagram: [Request Flow](diagrams/request-flow.d2)

```
Client → DNS → Ingress Controller → Service → Pod
```

1. Client makes HTTP request to `myapp.local`
2. DNS resolves to the Ingress Controller's IP
3. Ingress Controller matches the host/path rules
4. Forwards request to the target Service
5. Service load-balances to a matching Pod

## Gateway API (The Future)

The **Gateway API** is the successor to Ingress. It's more expressive, extensible, and role-oriented. While Ingress is still widely used, Gateway API is the recommended path for new projects.

Key differences:

| Feature | Ingress | Gateway API |
|---------|---------|-------------|
| Protocol | HTTP/HTTPS only | HTTP, HTTPS, TCP, UDP, gRPC |
| Role separation | Single resource | Gateway (infra) + Route (app) |
| Extensibility | Annotations (non-standard) | First-class extension points |
| Status | Stable, widely deployed | GA since K8s 1.26 |

### Gateway API Resources

```
GatewayClass → Gateway → HTTPRoute/TCPRoute/GRPCRoute
```

```yaml
# HTTPRoute example
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
spec:
  parentRefs:
    - name: my-gateway
  hostnames:
    - "myapp.local"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: web-service
          port: 80
```

> For this learning guide, we focus on Ingress because it's simpler and more widely deployed. Gateway API is covered as awareness for the future.

## Testing Locally

For local development, add entries to `/etc/hosts`:

```bash
# Add to /etc/hosts
echo "127.0.0.1 myapp.local api.myapp.local" | sudo tee -a /etc/hosts
```

Then access via browser or curl:

```bash
curl http://myapp.local
```

## Common kubectl Commands

```bash
# List Ingress resources
kubectl get ingress

# Describe an Ingress
kubectl describe ingress web-ingress

# Check Ingress Controller pods
kubectl get pods -n ingress-nginx

# View Ingress Controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

## Hands-On

- [Exercise 08: Networking →](../../exercises/08-networking/)

## What's Next?

- [RBAC →](09-rbac.md)
