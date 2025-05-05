# operation

This repository helps connect and run the services developed by REMLA 2025 Team 9. It uses Docker Compose to start everything locally for testing or demonstration purposes.

## How to Start

Make sure Docker and Docker Compose are installed. Then:

```bash
docker-compose up --build
```

To stop the services:

```bash
docker-compose down
```

If you're using GitHub Container Registry (GHCR) images and encounter permission errors, log in first:

```bash
echo $GH_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

---

## Repositories

### Operation

- Repository link: https://github.com/remla2025-team9/operation  
- Orchestrates all project services using `docker-compose`  
- Includes `README.md`, `docker-compose.yml`, and activity log for all assignments  

---

### app-service

- Repository link: https://github.com/remla2025-team9/app-service  

Flask-based web service providing the main API interface. Includes a `/healthcheck` route and is configured to run in a Docker container. CI/CD is enabled for automatic tagging, versioning, and image publishing.

**REPOSITORY SETUP INSTRUCTIONS:**

```bash
# Local development
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

# Or use Docker
docker build -t app-service .
docker run -p 5000:5000 app-service
```

---

### model-service

- Repository link: https://github.com/remla2025-team9/model-service  

Serves predictions from a trained ML model via a REST API. Built with Flask, containerized with Docker, and supports integration with `app-service`.

**REPOSITORY SETUP INSTRUCTIONS:**

```bash
# Local setup
pip install -r requirements.txt
python app.py

# Docker
docker build -t model-service .
docker run -p 5001:5001 model-service
```

---

### lib-version

- Repository link: https://github.com/remla2025-team9/lib-version  

Lightweight Python library with a `VersionUtil` class to retrieve the current version. Version is maintained in `__version__.py` and updated automatically using GitHub workflows.

**REPOSITORY SETUP INSTRUCTIONS:**

```bash
# Install locally
pip install .

# Test version retrieval
python -c "from lib_version.version_util import VersionUtil; print(VersionUtil.get_version())"
```

---

### lib-ml

- Repository link: https://github.com/remla2025-team9/lib-ml  

Contains shared logic for data preprocessing and any ML-related utilities. Used by both training and inference components.

**REPOSITORY SETUP INSTRUCTIONS:**

```bash
pip install .
# Usage depends on the specific modules within the library
```

---

### model-training

- Repository link: https://github.com/remla2025-team9/model-training  

Code for training ML models using datasets, including preprocessing, training, evaluation, and model saving.

**REPOSITORY SETUP INSTRUCTIONS:**

```bash
pip install -r requirements.txt
python train.py  # Adjust with correct CLI args if applicable
```

---

### app-frontend

- Repository link: https://github.com/remla2025-team9/app-frontend  

Frontend application showing the status of the system, version info, or predictions. Communicates with `app-service`.

**REPOSITORY SETUP INSTRUCTIONS:**

```bash
npm install
npm run dev
# Or build and serve:
npm run build
npm run preview
```
