SHELL := /usr/bin/env bash
STAGE ?= local

.DEFAULT_GOAL := all
.PHONY: all

all: format test deploy

test: test-format test-quality test-unit

deploy: clean package terraform-apply

install:
    ifeq ($(shell pyenv versions --bare | grep 3.12 | wc -l), 0)
		pyenv install 3.12;
    endif
	poetry config virtualenvs.prefer-active-python true
	pyenv local 3.12
	poetry self add poetry-plugin-export
	poetry install --with dev
	poetry run pre-commit install

clean:
	rm -rf dist build
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	find . | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs -r rm -rf

clear-poetry-cache:
	poetry env remove --all
	poetry cache clear pypi --all

format:
	find . -name "*.tf" -not -path "*.terraform*" | xargs -r terraform fmt
	-poetry run docformatter --config pyproject.toml .
	poetry run autoflake --in-place --recursive --remove-all-unused-imports .
	poetry run isort . --profile black
	poetry run black .

test-format:
	find . -name "*.sh" | xargs -r shellcheck
	find . -name "*.tf" -not -path "*.terraform*" | xargs -r terraform fmt -check
	poetry run docformatter --config pyproject.toml --check .
	poetry run autoflake --recursive --check .
	poetry run isort . --check-only --profile black
	poetry run black . --check

test-quality:
	poetry run bandit -r example
	poetry run bandit -r tests
	poetry run pylint --rcfile pyproject.toml example
	poetry run pylint --rcfile pyproject.toml tests

test-unit:
	sops exec-env .local.enc.env 'poetry run pytest tests/unit --disable-pytest-warnings'

run-example-dev:
	sops exec-env .dev.enc.env 'poetry run python -m example.handler.example'

run-example-prod:
	sops exec-env .prod.enc.env 'poetry run python -m example.handler.example'

import-gpg-keys:
	find .gpg -name "*.asc" | xargs cat - | gpg --import -

rotate-secrets: decrypt-secrets encrypt-secrets

decrypt-secrets:
	sops --decrypt .local.enc.env > .local.dec.env
	sops --decrypt .dev.enc.env > .dev.dec.env
	sops --decrypt .prod.enc.env > .prod.dec.env

encrypt-secrets:
	sops --encrypt .local.dec.env > .local.enc.env
	sops --encrypt .dev.dec.env > .dev.enc.env
	sops --encrypt .prod.dec.env > .prod.enc.env
	rm -f .local.dec.env
	rm -f .dev.dec.env
	rm -f .prod.dec.env

delete-secrets:
	rm -f .local.dec.env
	rm -f .dev.dec.env
	rm -f .prod.dec.env

terraform-plan:
	cd infra && terraform init -input=false -backend-config=../backend.$(STAGE).hcl
	cd infra && terraform plan -out=tfplan -var-file="../vars.$(STAGE).tfvars"
	cd infra && terraform show -json tfplan | jq

terraform-apply:
	cd infra && terraform init -input=false -backend-config=../backend.$(STAGE).hcl
	cd infra && terraform apply -auto-approve -var-file="../vars.$(STAGE).tfvars"

terraform-destroy:
	cd infra && terraform init -input=false -backend-config=../backend.$(STAGE).hcl
	cd infra && terraform destroy

backend: backend-plan backend-apply

backend-plan:
	cd infra/.tf-backend && terraform init -input=false
	cd infra/.tf-backend && terraform plan -state=backend.tfstate -out=backend.tfplan

backend-apply:
	cd infra/.tf-backend && terraform init -input=false
	cd infra/.tf-backend && terraform apply -state=backend.tfstate backend.tfplan

backend-destroy:
	cd infra/.tf-backend && terraform init -input=false
	cd infra/.tf-backend && terraform destroy -state=backend.tfstate

package:
	poetry install --only main --sync
	poetry build
	poetry run pip install --upgrade -t build dist/*.whl
	rm -rf dist
	find build -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	cd build && zip -r -q lambda.zip .

