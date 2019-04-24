# Set the shell
SHELL := /bin/bash

VERSION := $(shell cat VERSION.txt)
GITCOMMIT := $(shell git rev-parse --short HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
ifneq ($(GITUNTRACKEDCHANGES),)
	GITCOMMIT := $(GITCOMMIT)-dirty
endif
ifeq ($(GITCOMMIT),)
    GITCOMMIT := ${GITHUB_SHA}
endif
CTIMEVAR=-X $(PKG)/version.GITCOMMIT=$(GITCOMMIT) -X $(PKG)/version.VERSION=$(VERSION)
GO_LDFLAGS=-ldflags "-w $(CTIMEVAR)"
GO_LDFLAGS_STATIC=-ldflags "-w $(CTIMEVAR) -extldflags -static"

# Set our default go compiler
GO := go

# List the GOOS and GOARCH to build
GOOSARCHES = $(shell cat .goosarch)

CGO_ENABLED := 0

# Set any default go build tags.
BUILDTAGS :=

all: upload-zip

.PHONY: upload-zip
upload-zip: create-release
	UPLOAD_URL=$(shell cat /tmp/response.json)
	curl -H "Authorization: token ${GITHUB_TOKEN}" \
		-H 'Content-Type: application/zip' \
		-F "file=@${REPOSITORY}.zip;type=application/zip" \
		"${UPLOAD_URL}?name=${REPOSITORY}.zip"
	

.PHONY: create-release
create-release: build
	mkdir -p /tmp/
	touch /tmp/response.json
	curl -H "Authorization: token ${GITHUB_TOKEN}" \
		-d "{ \"tag_name\": \"${VERSION}\", \"target_commitish\": \"${GITHUB_REF}\" }" \
		"https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" -o /tmp/response.json
	cat /tmp/response.json
	cat /tmp/response.json \
		| jq --raw-output '.upload_url'
	cat /tmp/response.json \
		| jq --raw-output '.upload_url' > /tmp/response.json
	cat /tmp/response.json
	sed -i 's/{.*//g' /tmp/response.json
	cat /tmp/response.json

.PHONY: build
build: deps
	GOOS=linux GOARCH=amd64 go build -o $(REPOSITORY) main.go
	zip $(REPOSITORY).zip $(REPOSITORY)

.PHONY: deps
deps: env
	go get github.com/aws/aws-lambda-go/events
	go get github.com/aws/aws-lambda-go/lambda
	GO111MODULE=off go get -u gopkg.in/src-d/go-git.v4/...
	

.PHONY: env
env:
	printenv
	@echo "printing directely now"
	@echo $(REPOSITORY)
	@echo $(GITHUB_TOKEN)
	@echo $(GITHUB_SHA)
	@echo $(GITHUB_REF)
	@echo $(GITHUB_REPOSITORY)
	@echo "done printing directly"

.PHONY: bump-version
BUMP := patch
bump-version: ## Bump the version in the version file. Set BUMP to [ patch | major | minor ].
	@$(GO) get -u github.com/jessfraz/junk/sembump # update sembump tool
	$(eval NEW_VERSION = $(shell sembump --kind $(BUMP) $(VERSION)))
	@echo "Bumping VERSION.txt from $(VERSION) to $(NEW_VERSION)"
	echo $(NEW_VERSION) > VERSION.txt
	git add VERSION.txt
	git commit -vsam "Bump version to $(NEW_VERSION)"
	@echo "Run make tag to create and push the tag for new version $(NEW_VERSION)"

.PHONY: tag
tag: ## Create a new git tag to prepare to build a release.
	git tag -sa $(VERSION) -m "$(VERSION)"
	@echo "Run git push origin $(VERSION) to push your new tag to GitHub and trigger a travis build."

.PHONY: prebuild
prebuild:

.PHONY: build2
build2: prebuild $(NAME) ## Builds a dynamic executable or package.

$(NAME): $(wildcard *.go) $(wildcard */*.go) VERSION.txt
	@echo "+ $@"
	$(GO) build -tags "$(BUILDTAGS)" ${GO_LDFLAGS} -o $(NAME) .
