# operation

This repository helps connect and run the services developed by REMLA 2025 Team 9. It uses Docker Compose to start everything locally for testing or demonstration.

## How to Start

```bash
docker-compose up --build
```

Make sure you are authenticated with GitHub Container Registry (GHCR) if needed:
```bash
echo $GH_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

## Repositories

- **operation** — [operation](https://github.com/remla2025-team9/operation)
- **app-service** — [app-service](https://github.com/remla2025-team9/app-service): Flask app with /healthcheck
- **model-service** — [model-service](https://github.com/remla2025-team9/model-service): wraps trained model as a REST API
- **lib-version** — [lib-version](https://github.com/remla2025-team9/lib-version): version-aware utility
- **lib-ml** — [lib-ml](https://github.com/remla2025-team9/lib-ml): pre-processing logic
- **model-training** — [model-training](https://github.com/remla2025-team9/model-training): training pipeline
- **app-frontend** — [app-frontend](https://github.com/remla2025-team9/app-frontend): shows app + model version

## Assignment Progress
