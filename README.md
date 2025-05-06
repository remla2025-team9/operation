# operation

This repository helps connect and run the services developed by REMLA 2025 Team 9. It uses Docker Compose to start everything locally for testing or demonstration purposes.

## How to Start

Make sure Docker and Docker Compose are installed. Then:

Configure the env files for each service:
* app-service.env
* app-frontend.env
* model-service.env

```bash
docker-compose up -d
```

To stop the services:

```bash
docker-compose down
```

If you're using GitHub Container Registry (GHCR) images and encounter permission errors, log in first:

```bash
echo $GH_TOKEN | docker login ghcr.io -u ${USERNAME} --password-stdin
```

---

## Repositories

### Operation

- **Link:** https://github.com/remla2025-team9/operation  
- Orchestrates all project services using `docker-compose`, includes `README.md`, `docker-compose.yml`, and activity log for all assignments.

---

### app-service

- **Link:** https://github.com/remla2025-team9/app-service  
Flask-based API service with `/healthcheck` and `/version` routes. CI/CD enabled for automatic versioning and image publishing.

---

### model-service

- **Link:** https://github.com/remla2025-team9/model-service  
Provides ML model predictions via REST API. Pre-built with Docker support and integration with `app-service`.

---

### lib-version

- **Link:** https://github.com/remla2025-team9/lib-version  
Python utility library (`VersionUtil`) for retrieving and exposing library version in APIs.

---

### lib-ml

- **Link:** https://github.com/remla2025-team9/lib-ml  
Shared utilities for data preprocessing and ML-related logic, used by training and inference workflows.

---

### model-training

- **Link:** https://github.com/remla2025-team9/model-training  
Training pipelines for ML models with automated CI/CD workflows for artifact releases.

---

### app-frontend

- **Link:** https://github.com/remla2025-team9/app-frontend  
Frontend application displaying system status, version info, and predictions from `app-service`.

---

*For detailed setup and usage instructions for each service, refer to the respective repository README.*
