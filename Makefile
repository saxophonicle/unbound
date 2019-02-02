
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64
BUILD_OPTS		:=

DOCKERFILE_PATH	:= Dockerfile.${ARCH}

BUILD_DATE		:= $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ')
BUILD_VERSION	:= $(shell docker run --rm -w /app -v ${CURDIR}:/app alpine /app/utils/bump.sh ${DOCKERFILE_PATH})
APP_VERSION		:= $(shell echo ${BUILD_VERSION} | sed -r "s/(.+)-[0-9]+/\1/")
VCS_REF			:= $(shell git describe --tags --long --dirty --always)

DOCKER_TAG		:= ${ARCH}-${BUILD_VERSION}
IMAGE_NAME		:= ${DOCKER_REPO}:${DOCKER_TAG}

.DEFAULT_GOAL	:= help

## -- Usage --

## Display this help message
##
.PHONY: help
help:	# https://gist.github.com/prwhite/8168133
	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                     "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                     "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)

## Description:
##     - build image locally from source and create multiple docker tags
## Usage:
##     - make build [ARCH=] [BUILD_OPTS=]
## Commands:
##     - docker build
##     - docker tag
## Examples:
##     - make build
##     - make build ARCH=armv7hf
##     - make build BUILD_OPTS=--no-cache
## Tags:
##     - {repo}:{arch}
##     - {repo}:{arch}-{appversion}
##     - {repo}:{arch}-{appversion}-{revision}
##
.PHONY: build
build:
	docker build ${BUILD_OPTS} \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_VERSION=${BUILD_VERSION} \
	--build-arg VCS_REF=${VCS_REF} \
	--file ${DOCKERFILE_PATH} \
	--tag ${IMAGE_NAME} \
	.
	docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}
	docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}-${APP_VERSION}

## Description:
##     - push existing tagged images to docker repo
##       (requires "make build" and "docker login" prior to running)
## Usage:
##     - make push [ARCH=]
## Commands:
##     - docker push
## Examples:
##     - make push
##     - make push ARCH=armv7hf
## Tags:
##     - {repo}:{arch}
##     - {repo}:{arch}-{appversion}
##     - {repo}:{arch}-{appversion}-{revision}
##
.PHONY: push
push:
	docker push ${IMAGE_NAME}
	docker push ${DOCKER_REPO}:${ARCH}
	docker push ${DOCKER_REPO}:${ARCH}-${APP_VERSION}
ifeq "${ARCH}" "amd64"
	docker push ${DOCKER_REPO}:latest
endif

## Description:
##     - run unit and integration tests to validate DNSSEC
##       (amd64 only for now)
## Usage:
##     - make test
## Commands:
##     - docker-compose
## Examples:
##     - make test
##
.PHONY: test
test:
	docker-compose -f docker-compose.test.yml -p ci up --build --abort-on-container-exit

## Description:
##     - add and push new git tag with app version and new build revision
## Usage:
##     - make tag [ARCH=]
## Commands:
##     - git fetch
##     - git tag
##     - git push
## Examples:
##     - make tag
##     - make tag ARCH=armv7hf
## Tags:
##     - {appversion}-{revision + 1}
##
.PHONY: tag
tag:
	git fetch --tags
	git tag -a "${BUILD_VERSION}" -m "tagging release ${BUILD_VERSION}"
	git push --tags

## Description:
##     - build image locally and push to docker repo in one step
## Usage:
##     - make release [ARCH=] [BUILD_OPTS=]
## Commands:
##     - make build
##     - make push
## Examples:
##     - make release
##     - make release ARCH=armv7hf
##     - make release BUILD_OPTS=--no-cache
##
.PHONY: release
release:	build push