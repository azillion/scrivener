REPOSITORY := scrivener

all: upload-zip

.PHONY: upload-zip
upload-zip: create-release
	

.PHONY: create-release
create-release: build
	curl -v -H "Authorization: token $$GITHUB_TOKEN" \
		-d "{ \"tag_name\": $$GITHUB_SHA, \"target_commitish\": $$GITHUB_REF }" \
		"https://api.github.com/repos/$$GITHUB_REPOSITORY/releases"

.PHONY: build
build: deps
	GOOS=linux GOARCH=amd64 go build -o main main.go
	zip $(REPOSITORY).zip main

.PHONY: deps
deps:
	go get github.com/aws/aws-lambda-go/events
	go get github.com/aws/aws-lambda-go/lambda
	GO111MODULE=off go get -u gopkg.in/src-d/go-git.v4/...
	
