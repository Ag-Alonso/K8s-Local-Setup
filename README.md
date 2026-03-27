# K8s-Local-Setup

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.31-326ce5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![kind](https://img.shields.io/badge/kind-v0.25+-326ce5)](https://kind.sigs.k8s.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![D2 Diagrams](https://img.shields.io/badge/Diagrams-D2%20%2B%20TALA-purple)](https://d2lang.com/)

A comprehensive guide to setting up and learning Kubernetes locally on **Linux** and **macOS**. Includes tool comparisons, core concept documentation, professional diagrams, and 13 hands-on exercises.

## Quick Start

```bash
# 1. Install prerequisites (macOS example)
brew install docker kind kubectl

# 2. Clone this repository
git clone https://github.com/O11YTech/K8s-Local-Setup.git
cd K8s-Local-Setup

# 3. Create a local Kubernetes cluster
./scripts/setup-kind.sh

# 4. Verify your cluster
./scripts/verify-cluster.sh

# 5. Start learning!
# Open exercises/00-verify-setup/README.md
```

> **Estimated time:** Under 10 minutes from clone to running cluster.

## Why kind?

We recommend [**kind**](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) as the primary tool because:

- Runs **upstream Kubernetes** via kubeadm — skills transfer 1:1 to EKS/GKE/AKS
- Fast startup (~30s) with low resource usage (~500MB per node)
- Multi-node clusters for realistic setups
- Industry standard for CI/CD testing
- Official `kubernetes-sigs` project

> See [Tool Comparison](docs/02-tool-comparison/) for alternatives (k3d, minikube, OrbStack, and more).

## Table of Contents

### Documentation

| Section | Description |
|---------|-------------|
| [Introduction](docs/01-introduction/) | What is Kubernetes, who is this for |
| [Tool Comparison](docs/02-tool-comparison/) | 8 local K8s tools compared |
| [Setup Guides](docs/03-setup-guides/) | Step-by-step installation (kind, k3d, minikube) |
| [Core Concepts](docs/04-core-concepts/) | Architecture, Pods, Deployments, Services, and more |

### Exercises

| # | Exercise | Difficulty | Duration |
|---|----------|------------|----------|
| 00 | [Verify Setup](exercises/00-verify-setup/) | Beginner | 15 min |
| 01 | [First Pod](exercises/01-first-pod/) | Beginner | 30 min |
| 02 | [Deployments](exercises/02-deployments/) | Beginner | 45 min |
| 03 | [Services](exercises/03-services/) | Beginner | 45 min |
| 04 | [ConfigMaps & Secrets](exercises/04-configmaps-secrets/) | Beginner | 45 min |
| 05 | [Persistent Storage](exercises/05-persistent-storage/) | Intermediate | 60 min |
| 06 | [Rolling Updates](exercises/06-rolling-updates/) | Intermediate | 45 min |
| 07 | [Namespaces](exercises/07-namespaces/) | Intermediate | 30 min |
| 08 | [Networking](exercises/08-networking/) | Intermediate | 60 min |
| 09 | [Health Checks](exercises/09-health-checks/) | Intermediate | 45 min |
| 10 | [Observability Basics](exercises/10-observability-basics/) | Intermediate | 60 min |
| 11 | [Multi-Container Pods](exercises/11-multi-container-pods/) | Intermediate | 45 min |
| 12 | [Capstone: Guestbook](exercises/12-capstone/) | Advanced | 120 min |

### Diagrams

Professional D2 diagrams with TALA layout (light + dark themes):

- [K8s Architecture Overview](docs/01-introduction/diagrams/k8s-architecture-overview.d2)
- [Pod Lifecycle](docs/04-core-concepts/diagrams/pod-lifecycle.d2)
- [Service Types](docs/04-core-concepts/diagrams/service-types.d2)
- [Deployment Rolling Update](docs/04-core-concepts/diagrams/deployment-rolling-update.d2)
- [Storage Architecture](docs/04-core-concepts/diagrams/storage-architecture.d2)
- [Request Flow](docs/04-core-concepts/diagrams/request-flow.d2)
- [RBAC Model](docs/04-core-concepts/diagrams/rbac-model.d2)
- [Tool Landscape](docs/02-tool-comparison/diagrams/tool-landscape.d2)

Render all diagrams:
```bash
./scripts/render-diagrams.sh
```

## Repository Structure

```
K8s-Local-Setup/
├── README.md                          # This file
├── CLAUDE.md                          # AI assistant context
├── docs/
│   ├── 01-introduction/               # What is K8s
│   ├── 02-tool-comparison/            # 8 tools compared
│   ├── 03-setup-guides/               # Installation guides
│   ├── 04-core-concepts/              # 11 concept documents
│   └── diagrams/_shared/              # Reusable D2 classes
├── exercises/                         # 13 hands-on exercises
│   ├── 00-verify-setup/ ... 12-capstone/
│   └── each with manifests/ and solution/
├── scripts/                           # Setup and utility scripts
└── sample-apps/                       # Reference applications
```

## Prerequisites

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 4 cores |
| RAM | 4 GB | 8 GB |
| Disk | 10 GB | 20 GB |
| Docker | 20.10+ | Latest |

See [Prerequisites Guide](docs/03-setup-guides/prerequisites.md) for detailed installation instructions.

## Learning Path

```
Introduction → Tool Comparison → Setup Guide → Core Concepts → Exercises
```

1. Read the [Introduction](docs/01-introduction/) to understand K8s fundamentals
2. Review the [Tool Comparison](docs/02-tool-comparison/) (we recommend kind)
3. Follow the [Setup Guide](docs/03-setup-guides/kind-setup.md) for your chosen tool
4. Study [Core Concepts](docs/04-core-concepts/) alongside exercises
5. Complete [Exercises 00-12](exercises/) in order

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`feat/add-new-exercise`)
3. Follow existing patterns and conventions
4. Test all manifests against a kind cluster
5. Submit a pull request

## License

MIT
