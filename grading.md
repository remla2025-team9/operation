# Grading Self-Assessment

This document provides a self-assessment of our work for the Release Engineering course. Its purpose is to guide the grading process by clarifying our expected level of achievement for each rubric block, detailing where to find the implementation of specific requirements, and providing additional context for any solutions that might not be immediately obvious.

We have structured this document by assignment, with a subsection for each rubric block as defined in the course materials.

---

## Assignment 1

### Data Availability 

*   **Expected Level:** `Pass`
*   **Implementation:**
    - The GitHub organization follows the requested template
    - All relevant information is accessible
    - The `operation` folder contains the `grading.md` file
*   **Notes for the Grader:**

### Sensible Use Case 

*   **Expected Level:** `Pass`
*   **Implementation:**
    - The frontend allows querying the model
    - Additional interactions exist that allow users to change incorrect predictions
*   **Notes for the Grader:**

### Automated Release Process

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
    - **(Excellent)** After every push to main (and thus also after merging branches to main), the pre-version tag is automatically bumped using a counter (e.g. from `v0.0.1-pre-2` to `v0.0.1-pre-3`). This gives support for multiple versions of the same pre-release.
    - **(Excellent)**   We have implemented a deployment workflow that is triggered manually with the click of a button in the GitHub Actions tab for all repositories. The bump level (patch, minor, major) can be set for this workflow when triggering manually. If the previous version was a pre-release, the pre-tag is removed for the stable release (e.g. for a patch bump, `v0.0.1-pre-2` will become `v0.0.1`, and for a minor bump, `v0.0.1-pre-2` will become `v0.1.0`).
    - **(Excellent)**   `app-frontend`, `app-service`, and `model-service` have a multi-stage Dockerfile.
    - **(Excellent)**   The images that are automatically released by `app-frontend`, `app-service`, and `model-service` support the `amd64` and `arm64` architectures.
*   **Notes for the Grader:**

### Software Reuse in Libraries

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Exposing a Model via REST

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Docker Compose Operation

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

---

## Assignment 2

### Setting up (Virtual) Infrastructure

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)**  All VMs exist with correct hostnames, attached to a private network for inter-VM communication
    - **(Sufficient)**  VMs are directly reachable from host through a host-only network (192.168.56.* range)
    - **(Sufficient)**  VMs are provisioned with Ansible, completing within 5 minutes
    - **(Good)**        Vagrantfile uses loops and template arithmetic for defining node names and IPs
    - **(Good)**        Worker VM specifications are controlled via environment variables (WORKER_COUNT_ENV, WORKER_CPU_COUNT_ENV, WORKER_MEMORY_ENV)
    - **(Excellent)**   Extra arguments are passed to Ansible from Vagrant, including number of workers
    - **(Excellent)**   Vagrant generates a valid inventory.cfg for Ansible containing all active nodes
*   **Notes for the Grader:**
    - The Vagrantfile is in the `/vagrant` directory
    - Environment variables can be found in the README.md documentation
    - Ansible playbooks are in the `/vagrant/ansible` directory
    - Host configuration is generated via the `hosts.j2` template

### Setting up Software Environment

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Setting up Kubernetes

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

---

## Assignment 3

### Kubernetes Usage

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Helm Installation

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### App Monitoring

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Grafana

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

---

## Assignment 4

### Automated Tests

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Continuous Training

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Project Organization

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Pipeline Management with DVC

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Code Quality

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

---

## Assignment 5

### Traffic Management

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Additional Use Case

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Continuous Experimentation

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Deployment Documentation

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**

### Extension Proposal

*   **Expected Level:** `[Your Expected Level]`
*   **Implementation:**
*   **Notes for the Grader:**
