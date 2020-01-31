DATE := $(shell date +%FT%T%z)
USER := $(shell whoami)
GIT_HASH := $(shell git --no-pager describe --tags --always)
BRANCH := $(shell git branch | grep \* | cut -d ' ' -f2)

LINT_FLAGS := run --deadline=120s
LINTER := ./bin/golangci-lint
TESTFLAGS := -v -cover -race -coverprofile=coverage.txt -covermode=atomic

GO111MODULE := on
all: $(LINTER) deps test lint build

$(LINTER):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s v1.15.0

.PHONY: lint
lint: $(LINTER)
	$(LINTER) $(LINT_FLAGS) ./...

.PHONY: deps
deps:
	go get .

.PHONY: test
test:
	go test $(TESTFLAGS) ./...

.PHONY: build
build: deps
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-s -X github.com/prometheus/common/version.Version=$(GIT_HASH) -X github.com/prometheus/common/version.BuildDate="$(DATE)" -X github.com/prometheus/common/version.Branch=$(BRANCH) -X github.com/prometheus/common/version.Revision=$(GIT_HASH) -X github.com/prometheus/common/version.BuildUser=$(USER) -extldflags "-static"' .
