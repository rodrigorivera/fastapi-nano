path := .

PROJECT=fnano
## Ensure this is the same name as in docker-compose.yml file
CONTAINER_NAME="${PROJECT}_${USER}"
PROJ_DIR="/mnt"
VERSION_FILE:=VERSION
COMPOSE_FILE=docker-compose.yml
TAG:=$(shell cat ${VERSION_FILE})

define Comment
	- Run `make help` to see all the available options.
	- Run `make lint` to run the linter.
	- Run `make lint-check` to check linter conformity.
	- Run `dep-lock` to lock the deps in 'requirements.txt' and 'requirements-dev.txt'.
	- Run `dep-sync` to sync current environment up to date with the locked deps.
endef


.PHONY: lint
lint: black isort flake mypy	## Apply all the linters.


.PHONY: lint-check
lint-check:  ## Check whether the codebase satisfies the linter rules.
	@echo
	@echo "Checking linter rules..."
	@echo "========================"
	@echo
	@black --check $(path)
	@isort --check $(path)
	@flake8 $(path)
	@mypy $(path)


.PHONY: black
black: ## Apply black.
	@echo
	@echo "Applying black..."
	@echo "================="
	@echo
	@black --fast $(path)
	@echo


.PHONY: isort
isort: ## Apply isort.
	@echo "Applying isort..."
	@echo "================="
	@echo
	@isort $(path)


.PHONY: flake
flake: ## Apply flake8.
	@echo
	@echo "Applying flake8..."
	@echo "================="
	@echo
	@flake8 $(path)


.PHONY: mypy
mypy: ## Apply mypy.
	@echo
	@echo "Applying mypy..."
	@echo "================="
	@echo
	@mypy $(path)


.PHONY: help
help: ## Show this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: test
test: ## Run the tests against the current version of Python.
	pytest


.PHONY: dep-lock
dep-lock: ## Freeze deps in 'requirements.txt' file.
	@pip-compile requirements.in -o requirements.txt --no-emit-options
	@pip-compile requirements-dev.in -o requirements-dev.txt --no-emit-options 


.PHONY: dep-sync
dep-sync: ## Sync venv installation with 'requirements.txt' file.
	@pip-sync

.PHONY: dep-update
dep-update: ## Update all the deps.
	@chmod +x ./scripts/update_deps.sh
	@./scripts/update_deps.sh

# Useful when Dockerfile/requirements are updated)
dev-rebuild: .env ## Rebuild images for dev containers
	docker-compose -f $(COMPOSE_FILE) --project-name $(PROJECT) up -d --build

.PHONY: dev-start
dev-start: .env ## Primary make command for devs, spins up DS containers
	docker-compose -f $(COMPOSE_FILE) --project-name $(PROJECT) up --no-recreate -d

.PHONY: dev-stop
dev-stop: ## Spin down active containers
	docker-compose -f $(COMPOSE_FILE) --project-name $(PROJECT) down

bash: dev-start ## Provides an interactive bash shell in the container
	docker exec -it $(CONTAINER_NAME) bash


.PHONY: run-local
run-local: ## Run the app locally.
	uvicorn app.main:app --port 5000 --reload
