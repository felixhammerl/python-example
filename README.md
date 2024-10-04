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

In this repository, secrets are never stored on disk in plain text in regular usage. Here is how you interact with secrets:

- `make import-gpg-keys`: Imports the GPG key from the `.gpg` directory.
- `make decrypt-secrets`: Decrypts secrets files into a gitignored file, in case changes need to be made.
- `make encrypt-secrets`: Encrypts the secrets files and removes the plain text equivalents.
- `make rotate-secrets`: Re-encrypts secrets files.

This repository uses `sops` to encrypt its secrets. For local development and in the CI, GPG is used as crypto backend. If you wish to be able to decrypt the secrets, please add your key to the `.sops.yaml` file.

In regular development, the secrets are to be injected into the running process or piped around. The rest should be handled by automation.

In order to be able to encrypt the secrets for your team members and the pipeline, please add your own public key to `.gpg`. Please make sure that all public keys in this repositories are imported into your GPG keyring via: `cat .gpg/<key>.asc | gpg import -`.

# Run locally

To run the project locally, you can use the following commands:

- `make run-example-dev`
- `make run-example-prod`
