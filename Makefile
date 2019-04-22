all: upload-zip

.PHONY: upload-zip
upload-zip: create-release
	curl -H "Authorization: token $GITHUB_TOKEN" \
		-H 'Content-Type: application/zip' \
		-F "file=@scrivener.zip;type=application/zip" \
		"$(UPLOAD_URL)?name=scrivener.zip"
	

.PHONY: create-release
create-release: build
	UPLOAD_URL=$(curl -H "Authorization: token $GITHUB_TOKEN" \
		-d "{ \"tag_name\": $GITHUB_SHA, \"target_commitish\": $GITHUB_REF }" \
		https://api.github.com/repos/$GITHUB_REPOSITORY/releases \
		| jq --raw-output '.upload_url' \
		| sed 's/{.*//g')

.PHONY: build
build: deps
	GOOS=linux GOARCH=amd64 go build -o main main.go
	zip scrivener.zip main

.PHONY: deps
deps:
	go get github.com/aws/aws-lambda-go/events
	go get github.com/aws/aws-lambda-go/lambda
	GO111MODULE=off go get -u gopkg.in/src-d/go-git.v4/...
	
