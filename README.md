# operation
## Instructions
<!-- An explanation on how to start the application (e.g., parameters, variables, requirements)-->
## Relevant Files
<!-- Pointers to relevant files that help outsiders understand the code base-->
## Repositories

### Operation

- Repository link: https://github.com/remla2025-team9/operation


### Model Training

- Repository link: https://github.com/remla2025-team9/model-training/tree/a1

This repository contains the training pipeline for the sentiment analysis model. It is also responsible for releasing the model to be used in the model service for real-time predictions for our application.

**REPOSITORY SETUP INSTRUCTIONS:**

The instructions to setup the repository and train/acquire a model can be found in the [README](https://github.com/remla2025-team9/model-training/blob/a1/README.md) of the repository.

**IMPLEMENTED FUNCTIONALITY:**

- The model training pipeline can successfully train a model and generate a model artifact to be used in the model service.
- Workflow for CI on every PR to the main branch to ensure that the model training pipeline is working correctly.
- Workflow for Continuous Development for automated versioning of the branch (pre-releases) and automatic release of a pre-release version of the model artifact to be used in the model service.
- Workflow for Continuous Deployment for a successful full release of the model as artifact to be used in the model service. Additional automated version bumping for the main branch after each successful release


### lib-ml

- Repository link: [ADD LINK HERE]

This repository contains the library for data preprocessing that is used by the model training and model service repositories. It is responsible for the data preprocessing pipeline for the sentiment analysis model.

**REPOSITORY SETUP INSTRUCTIONS:**

THe instructions to setup the repository and train/acquire a model can be found in the [README]([INSERT THE LINK HERE]) of the repository.

**IMPLEMENTED FUNCTIONALITY:**

### Model Service
- Repository link: [ADD LINK HERE]

This repository contains the model service for the sentiment analysis model. It is responsible for serving the model to be used in the application.

**REPOSITORY SETUP INSTRUCTIONS:**

The instructions to setup the repository and train/acquire a model can be found in the [README]([INSERT THE LINK HERE]) of the repository.

**IMPLEMENTED FUNCTIONALITY:**

### lib-version
- Repository link: [ADD LINK HERE]

[ADD DESCRIPTION HERE]

**REPOSITORY SETUP INSTRUCTIONS:**
The instructions to setup the repository and train/acquire a model can be found in the [README]([INSERT THE LINK HERE]) of the repository.

**IMPLEMENTED FUNCTIONALITY:**

### App Frontend
- Repository link: [ADD LINK HERE]
- 
This repository contains the frontend for the application. It is responsible for serving the frontend of the application to be used by the users.

**REPOSITORY SETUP INSTRUCTIONS:**
The instructions to setup the repository and train/acquire a model can be found in the [README]([INSERT THE LINK HERE]) of the repository.

**IMPLEMENTED FUNCTIONALITY:**

### App Service
- Repository link: [ADD LINK HERE]

This repository contains the backend for the application. It is responsible for serving the backend of the application to be used by the users.

**REPOSITORY SETUP INSTRUCTIONS:**
The instructions to setup the repository and train/acquire a model can be found in the [README]([INSERT THE LINK HERE]) of the repository.

**IMPLEMENTED FUNCTIONALITY:**
