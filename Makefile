all: upload-zip

.PHONY: upload-zip
upload-zip: create-release
	curl -H "Authorization: token ${GITHUB_TOKEN}" \
		-H 'Content-Type: application/zip' \
		-F "file=@${REPOSITORY}.zip;type=application/zip" \
		"${UPLOAD_URL}?name=${REPOSITORY}.zip"
	

.PHONY: create-release
create-release: build
	curl -H "Authorization: token ${GITHUB_TOKEN}" \
		-d "{ \"tag_name\": ${GITHUB_SHA}, \"target_commitish\": ${GITHUB_REF} }" \
		"https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" -o /tmp/response.json
	cat /tmp/response.json
	UPLOAD_URL=$(shell cat /tmp/response.json \
		| jq --raw-output '.upload_url' \
		| sed 's/{.*//g')

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
