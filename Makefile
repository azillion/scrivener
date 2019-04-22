build: deps
	GOOS=linux GOARCH=amd64 go build -o main main.go
	zip main.zip main

deps:
	go get github.com/aws/aws-lambda-go/events
	go get github.com/aws/aws-lambda-go/lambda
	GO111MODULE=off go get -u gopkg.in/src-d/go-git.v4/...
	
