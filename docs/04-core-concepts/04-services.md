# Services

## The Problem

Pods are ephemeral — they can be created, destroyed, and rescheduled at any time. Each pod gets a unique IP address, but that IP changes when the pod is replaced. You need a stable way to reach your application.

## What is a Service?

A **Service** is a stable network endpoint that routes traffic to a set of pods. It provides:

- A **stable IP address** (ClusterIP) that doesn't change
- A **DNS name** (e.g., `my-service.default.svc.cluster.local`)
- **Load balancing** across matching pods
- **Service discovery** for other applications

## How Services Find Pods

Services use **label selectors** to find their target pods:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx              # Route traffic to pods with label app=nginx
  ports:
    - port: 80              # Service port (what clients connect to)
      targetPort: 80        # Container port (where the app listens)
      protocol: TCP
```

Any pod with the label `app: nginx` receives traffic from this service, regardless of which node it's running on.

## Service Types

> See the full diagram: [Service Types](diagrams/service-types.d2)

### ClusterIP (default)

Internal-only access within the cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP            # Default, can be omitted
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 8080
```

- Accessible at: `backend-service.default.svc.cluster.local:80`
- Use for: service-to-service communication

### NodePort

Exposes the service on a static port on every node.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - port: 80               # ClusterIP port
      targetPort: 8080       # Container port
      nodePort: 30080        # External port (30000-32767)
```

- Accessible at: `<any-node-ip>:30080`
- Use for: development, testing, simple external access

### LoadBalancer

Provisions an external load balancer (in cloud environments).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-lb
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080
```

- Accessible at: external IP assigned by cloud provider
- Use for: production external access
- In local clusters: requires MetalLB or similar (or `minikube tunnel`)

### ExternalName

Maps a service to a DNS name. No proxying, just a CNAME record.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  type: ExternalName
  externalName: db.example.com
```

## DNS in Kubernetes

Every service gets a DNS entry automatically:

```
<service-name>.<namespace>.svc.cluster.local
```

Examples:
- `nginx-service.default.svc.cluster.local`
- `backend.production.svc.cluster.local`

Within the same namespace, you can use just the service name:

```bash
# From a pod in the "default" namespace
curl http://nginx-service        # Works!
curl http://nginx-service:80     # Also works
```

## Endpoints

Behind the scenes, a Service maintains an **Endpoints** object listing the IP addresses of matching pods:

```bash
$ kubectl get endpoints nginx-service
NAME            ENDPOINTS                                   AGE
nginx-service   10.244.0.5:80,10.244.1.3:80,10.244.2.4:80  5m
```

When pods are added or removed, endpoints update automatically.

## Port Mapping

```yaml
ports:
  - name: http              # Name (required if multiple ports)
    port: 80                # Service port — what clients use
    targetPort: 8080        # Container port — where the app listens
    protocol: TCP           # TCP (default) or UDP
```

You can also reference the container port by name:

```yaml
# In the pod spec
ports:
  - name: http
    containerPort: 8080

# In the service spec
ports:
  - port: 80
    targetPort: http        # References the named port
```

## Common kubectl Commands

```bash
# Create a service
kubectl apply -f service.yaml

# List services
kubectl get services
kubectl get svc                   # Short form

# Describe a service
kubectl describe svc nginx-service

# View endpoints
kubectl get endpoints nginx-service

# Quick service creation (expose a deployment)
kubectl expose deployment nginx-deployment --port=80 --target-port=80

# Test service from within the cluster
kubectl run tmp --image=busybox --rm -it -- wget -qO- http://nginx-service
```

## Hands-On

- [Exercise 03: Services →](../../exercises/03-services/)

## What's Next?

- [ConfigMaps & Secrets →](05-configmaps-secrets.md)
