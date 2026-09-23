ARG TF_IMAGE="hashicorp/terraform"
ARG TF_VERSION="LATEST"
ARG PYTHON_VERSION="3.14"

FROM  ${TF_IMAGE}:${TF_VERSION} AS base

ARG TF_VERSION
ARG PYTHON_VERSION
ARG UID=1000
ARG GID=1000

LABEL name="terrapy"
LABEL version=$TF_VERSION-$PYTHON_VERSION

RUN apk add --no-cache zip python3~$PYTHON_VERSION py3-pip

RUN addgroup -g ${GID} docker && adduser -u ${UID} -G docker -s /bin/sh -D docker

HEALTHCHECK CMD docker version && terraform version && python3 --version

USER ${UID}:${GID}