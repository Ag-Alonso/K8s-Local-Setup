# K8s-Local-Setup

## Project Overview

Educational repository for learning Kubernetes locally. Target audience: beginners.
Primary tool: **kind** (Kubernetes IN Docker). Covers setup, core concepts, and hands-on exercises.

## Structure

- `docs/` - Documentation organized by topic (introduction, tool comparison, setup guides, core concepts)
- `exercises/` - Progressive hands-on exercises (00-12), each with manifests/ and solution/
- `scripts/` - Setup and utility scripts (bash, must pass shellcheck)
- `sample-apps/` - Reference applications for exercises

## Conventions

- All manifests use raw YAML (no Helm) - this is a fundamentals course
- D2 diagrams use TALA layout with dual theme (light 0, dark 200)
- Shared D2 classes in `docs/diagrams/_shared/diagram-classes.d2`
- Exercise numbering: `XX-name/` with README.md, manifests/, solution/
- Cross-links between concepts and exercises use relative paths

## Commands

- Render diagrams: `./scripts/render-diagrams.sh`
- Setup kind cluster: `./scripts/setup-kind.sh`
- Verify cluster: `./scripts/verify-cluster.sh`

## Writing Style

- Clear, beginner-friendly language
- Step-by-step instructions with validation checkpoints
- Code blocks with comments explaining each field
- Always show expected output after kubectl commands
