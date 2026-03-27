# Core Concepts

This section covers the fundamental Kubernetes concepts you need to understand before working with clusters. Each concept builds on the previous ones — work through them in order.

## Learning Path

| # | Concept | What You'll Learn | Exercise |
|---|---------|-------------------|----------|
| 01 | [Architecture](01-architecture.md) | Control plane, nodes, how K8s works | — |
| 02 | [Pods](02-pods.md) | Smallest deployable unit | [01-first-pod](../../exercises/01-first-pod/) |
| 03 | [ReplicaSets & Deployments](03-replicasets-deployments.md) | Scaling and managing pod replicas | [02-deployments](../../exercises/02-deployments/) |
| 04 | [Services](04-services.md) | Networking and load balancing | [03-services](../../exercises/03-services/) |
| 05 | [ConfigMaps & Secrets](05-configmaps-secrets.md) | Configuration management | [04-configmaps-secrets](../../exercises/04-configmaps-secrets/) |
| 06 | [Namespaces](06-namespaces.md) | Resource isolation | [07-namespaces](../../exercises/07-namespaces/) |
| 07 | [Volumes](07-volumes.md) | Persistent storage | [05-persistent-storage](../../exercises/05-persistent-storage/) |
| 08 | [Ingress & Gateway API](08-ingress-gateway-api.md) | External access to services | [08-networking](../../exercises/08-networking/) |
| 09 | [RBAC](09-rbac.md) | Access control | — |
| 10 | [Labels & Selectors](10-labels-selectors.md) | Organizing and querying resources | — |
| 11 | [Workload Types](11-workload-types.md) | Jobs, CronJobs, DaemonSets, StatefulSets | [11-multi-container-pods](../../exercises/11-multi-container-pods/) |

## Diagrams

Visual references for key concepts:

- [Kubernetes Architecture Overview](../01-introduction/diagrams/k8s-architecture-overview.d2)
- [Pod Lifecycle](diagrams/pod-lifecycle.d2)
- [Service Types](diagrams/service-types.d2)
- [Deployment Rolling Update](diagrams/deployment-rolling-update.d2)
- [Storage Architecture](diagrams/storage-architecture.d2)
- [Request Flow](diagrams/request-flow.d2)
- [RBAC Model](diagrams/rbac-model.d2)

## How to Use This Section

1. **Read** the concept document
2. **Study** the associated diagram
3. **Complete** the linked exercise
4. **Review** the solution if you get stuck

Each concept document includes:
- A plain-language explanation
- Key terminology
- YAML examples with comments
- Common kubectl commands
- Links to exercises for hands-on practice
