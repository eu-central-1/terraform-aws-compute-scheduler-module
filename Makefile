SHELL = /bin/bash


define PROJECT_HELP_MSG
Usage:\n
  make help     \t show this message\n
  make clean    \t remove intermediate files\n
  \n
  make install  \t install terraform modules and local backend\n
  \n
  make tests    \t run local tests to check things like 'terraform plan' at module level\n
  make deploy   \t test example deployment from examples/subdir to personal AWS account\n
  make destroy  \t destroy example deployment from examples/subdir to personal AWS account\n
  make env      \t login to personal AWS account and export .env file (needed for deploy and destroy)\n
  \n
  make checks   \t Run static code analysis on Terraform code using Checkov\n
  make docs     \t generate module documentation using terraform-docs in docs/USAGE.md\n
\n
Type Q to continue
endef
export PROJECT_HELP_MSG

help:
	echo -e $$PROJECT_HELP_MSG | less

ifeq ($(OSTYPE),Windows_NT)
    uname_S := Windows
else
    uname_S := $(shell uname -s)
endif

SUBDIR=examples/quickstart
TOPDIR=$(shell pwd)
TF_IMAGE=hashicorp/terraform
TF_VERSION=1.16
UID=$(id -u)
GID=$(getent group docker | cut -d: -f3)
SED_INPLACE_OPT=$(shell sed --version &>/dev/null && echo "--in-place" || echo "-i ''")
TERRAPY_IMAGE=terrapy:${TF_VERSION}-${PYTHON_VERSION}
TERRAPY_BUILD_ARGS=--build-arg TF_IMAGE=${TF_IMAGE} --build-arg TF_VERSION=${TF_VERSION} --build-arg PYTHON_VERSION=${PYTHON_VERSION}
TERRAPY_BUILD_ARGS=${TERRAPY_BUILD_ARGS} --build-arg UID=${UID} --build-arg GID=${GID}

# Following is for shorten the docker commands below. Please take time to read and understand all of it, before changing
WORKSPACE_VOLUME=--volume ${TOPDIR}:/workspace --workdir /workspace
DOCKER_SOCKET=--volume /var/run/docker.sock:/var/run/docker.sock --user=${UID}:${GID}

PYTHON_VERSION=3.14

.terraform.lock.hcl:
	# Initialize all Terraform modules
	docker run --rm ${WORKSPACE_VOLUME} ${TERRAPY_IMAGE} init

.PHONY: terrapy
terrapy:
	# Build new Terraform docker image including Python
	docker build --build-arg TF_IMAGE=${TF_IMAGE} --build-arg TF_VERSION=${TF_VERSION} --build-arg PYTHON_VERSION=${PYTHON_VERSION} -t ${TERRAPY_IMAGE} .

.PHONY: install
install: terrapy .terraform.lock.hcl

SKIP_CHECKS=MEDIUM,CKV_TF_1

.PHONY: check
checks:
	# Run code analysis using Checkov
	docker run --tty ${WORKSPACE_VOLUME} bridgecrew/checkov --directory /workspace --skip-check ${SKIP_CHECKS}

tests: install
	# Running local testing with mocks
	docker run --rm ${DOCKER_SOCKET} ${WORKSPACE_VOLUME} ${TERRAPY_IMAGE} test

.PHONY: docs
docs:
	# Generate module documentation using terraform-docs in docs/USAGE.md
	docker run --rm --volume "${TOPDIR}:/terraform-docs" quay.io/terraform-docs/terraform-docs:0.18.0 markdown /terraform-docs > docs/USAGE.md

.env:
	# Login to personal AWS account and export .env file (needed for deploy and destroy)
	# Remove quotes from environment variables because of https://github.com/docker/cli/issues/3630
	touch .env
	assume --env && sed ${SED_INPLACE_OPT} 's/"//g' .env || (aws configure export-credentials --format env-no-export >.env)

.PHONY: env
env: .env

deploy: clean env
	# Test example deployment from examples/subdir to personal AWS account
	docker run --rm --env-file .env ${DOCKER_SOCKET} ${WORKSPACE_VOLUME}/${SUBDIR} ${TERRAPY_IMAGE} init
	docker run --rm --env-file .env ${DOCKER_SOCKET} ${WORKSPACE_VOLUME}/${SUBDIR} ${TERRAPY_IMAGE} apply -auto-approve

destroy: env
	# Destroy example deployment from examples/subdir to personal AWS account
	docker run --rm --env-file .env ${DOCKER_SOCKET} ${WORKSPACE_VOLUME}/${SUBDIR} ${TERRAPY_IMAGE} init
	docker run --rm --env-file .env ${DOCKER_SOCKET} ${WORKSPACE_VOLUME}/${SUBDIR} ${TERRAPY_IMAGE} apply -destroy -auto-approve

.PHONY: clean
clean:
	# Remove intermediate files
	-rm .env
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
