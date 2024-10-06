This is a bootstrap repository for a Python project. It includes:

- A Makefile for common tasks
- A `pyproject.toml` file for Poetry
- The folder structure for a Python project
- SOPS for secrets management
- A `.gitignore` file
- A Github Actions workflow for CI
- A `.pre-commit-config.yaml` file for pre-commit hooks
- A Terraform setup to deploy to a Lambda function
- A multi-stage setup for your infrastructure:
  - `local`: Your local development environment
  - `dev`: The deployed non-production environment
  - `prod`: The deployed production environment

# Before we start

It is assumed that you have a working setup of:

- [Poetry](https://python-poetry.org/)
- [pyenv](https://github.com/pyenv/pyenv)
- [shellcheck](https://www.shellcheck.net/)
- [terraform](https://www.terraform.io/)
- [sops](https://github.com/getsops/sops)
- [gnupg](https://gnupg.org/)

# Getting started

- To get started: `make install`
- To start over, destroy the virtual env, and nuke all caches: `make clean`

# Secrets

Secrets should never be stored on disk in plain text in regular usage. This repository uses `sops` to encrypt its secrets. For local development and in the CI, GPG is used as crypto backend. If you wish to be able to decrypt the secrets, please add your key to the `.sops.yaml` file.

Here is how you interact with secrets:

- `make import-gpg-keys`: Imports the GPG key from the `.gpg` directory.
- `make decrypt-secrets`: Decrypts secrets files into a gitignored file, in case changes need to be made.
- `make encrypt-secrets`: Encrypts the secrets files and removes the plain text equivalents.
- `make rotate-secrets`: Re-encrypts secrets files. This is useful when a new team member joins or leaves.

In regular development, the secrets are to be injected into the running process or piped around. The rest should be handled by automation.

In order to be able to encrypt the secrets for your team members and the pipeline, please add your own public key to `.gpg`. Please make sure that all public keys in this repositories are imported into your GPG keyring via: `make import-gpg-keys`

# Testing

To run the tests, you can use the following commands:

- `make test-format`: Runs the formatting tests (black, isort, docformatter, autoflake, shellcheck, terraform)
- `make test-quality`: Runs the quality tests (bandit, pylint)
- `make test-unit`: Runs the unit tests
- `make test`: Runs all tests

To run and debug the tests in VSCode, you need to use `make decrypt-secrets` to decrypt the plain text `.<local/dev/prod>.dec.env` files. Then you can run the tests in the debugger.

To run the project locally, you can use the following commands:

- `make run-example-dev`
- `make run-example-prod`

This uses `sops` to decrypt the `.env` file and injects the secrets into the running process.

# Build & Deployment

The backend for the Terraform state is stored in an S3 bucket and a DynamoDB lock. To manage the backend, you can use the following commands:

- `make backend-plan`: Creates the backend plan for the Terraform state.
- `make backend-apply`: Applies the backend plan to create the backend.
- `make backend-destroy`: Destroys the backend.

This is a one-time operation and only encompasses the `infra/.tf-backend`. Once the backend is created, store the state for the backend in version control in case changes need to be made.

To build/package the source code, you can use the following commands:

- `make package`: Packages the Python project into a zip file (`build/lambda.zip`) to be stored in S3 and deployed to Lambda.

To manage the infrastructure, you can use the following commands:

- `make terraform-plan`: (Optional) Outputs the Terraform plan as JSON in the console. This is only for debugging.
- `make terraform-apply`: Applies all changes to the infrastructure. Does not use the plan!
- `make terraform-destroy`: Destroys all infrastructure.
