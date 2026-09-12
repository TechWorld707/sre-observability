# MiniShop

Small ecommerce application for Kubernetes practice.

## Components

- Frontend: HTML/CSS/JavaScript served by Nginx
- Backend: FastAPI + SQLAlchemy
- Database: PostgreSQL
- Health endpoints:
  - `/healthz`
  - `/readyz`

## Run locally

```bash
docker compose up --build
```

Open:

```text
http://localhost:8080
```

## Useful API routes

```text
GET  /api/products
GET  /api/orders
POST /api/orders
GET  /healthz
GET  /readyz
```

## Kubernetes learning

This application is intentionally small so you can focus on:

- Deployments and Services
- StatefulSets and PVCs
- ConfigMaps and Secrets
- readiness/liveness probes
- rolling updates and rollback
- ECR image pulls
- Trivy scanning
- Argo CD GitOps
- Ingress
- NetworkPolicy
- HPA
- troubleshooting
