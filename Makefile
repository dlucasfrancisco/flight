COMMIT=$(shell git rev-parse --short HEAD)
BUILD_TIME=$(shell date -u +%s)

LDFLAGS=-ldflags "-X main.commitHash=$(COMMIT) -X main.buildTime=$(BUILD_TIME)"

.PHONY: all
all: vendor build test integration-test e2e-test

.PHONY: bootstrap
bootstrap: vendor

###### Docker builds (For Integration purposes)
##########################################################################

.PHONY: clean
clean:
	@echo "Cleaning workspace on COMMIT: $(COMMIT)"
	docker-compose -f docker/clean.yml -p $(COMMIT) up --abort-on-container-exit
	docker-compose -f docker/clean.yml -p $(COMMIT) down
	docker/scripts/runContainersClean.sh $(COMMIT)

.PHONY: vendor
vendor:
	@echo "Running vendor build on COMMIT: $(COMMIT)"
	docker-compose -f docker/vendor.yml -p $(COMMIT) up --abort-on-container-exit
	docker-compose -f docker/vendor.yml -p $(COMMIT) down

.PHONY: test
test: mocks
	@echo "Running unit tests and generating reports on COMMIT: $(COMMIT)"
	docker-compose -f docker/utest.yml -p $(COMMIT) up --abort-on-container-exit
	docker-compose -f docker/utest.yml -p $(COMMIT) down

integration-test:
	@echo "Running integration tests and generating reports on COMMIT: $(COMMIT)"
	docker-compose -f docker/itest.yml -p $(COMMIT) up --build --abort-on-container-exit
	docker-compose -f docker/itest.yml -p $(COMMIT) down

.PHONY: e2e-test
e2e-test:
	@echo "Running e2e tests and generating reports on COMMIT: $(COMMIT)"
	docker-compose -f docker/e2etest.yml -p $(COMMIT) up --build --abort-on-container-exit
	docker-compose -f docker/e2etest.yml -p $(COMMIT) down

.PHONY: build
build:
	@echo "Running build of COMMIT: $(COMMIT)"
	docker-compose -f docker/build.yml -p $(COMMIT) up --abort-on-container-exit
	docker-compose -f docker/build.yml -p $(COMMIT) down

start_service:
	@echo "Deploying service"
	docker-compose -f docker/deploy.yml -p $(COMMIT) up --build

.PHONY: mocks
mocks:
	@echo "Generating mocks"
	docker-compose -f docker/mocks.yml -p $(COMMIT) up --abort-on-container-exit
	docker-compose -f docker/mocks.yml -p $(COMMIT) down

###### Local builds	(For Dev purposes)
##########################################################################

.PHONY: clean-local
clean-local:
	@echo "Cleaning workspace..."
	rm -rf vendor/
	rm -rf bin/
	rm -rf mocks/
	rm -rf coverage/


.PHONY: vendor-local
vendor-local:
	rm -rf vendor/*
	glide install
	glide update


.PHONY: test-local
test-local:
	@echo "Running unit tests and generating reports"
	docker/scripts/runUTest.sh

.PHONY: build-local
build-local:
	@echo "Running  build"
	docker/scripts/runBuild.sh

.PHONY: mocks-local
mocks-local:
	@echo "Generating mocks"
	docker/scripts/runMocks.sh

###### Docker Builds
##############################

.PHONY: build-docker-image
build-docker-image:
	docker/scripts/runBuildDockerImage.sh $(TARGET) $(COMMIT) $(BRANCH)