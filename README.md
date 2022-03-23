# Hello world docker action
- A detailed description of what the action does.
- Required input and output arguments.
- Optional input and output arguments.
- Secrets the action uses.
- Environment variables the action uses.
- An example of how to use your action in a workflow.

!!! add $ chmod +x entrypoint.sh

This action prints "Hello World" or "Hello" + the name of a person to greet to the log.

## Inputs

## `who-to-greet`

**Required** The name of the person to greet. Default `"World"`.

## Outputs

## `time`

The time we greeted you.

## Example usage

uses: actions/hello-world-docker-action@v1
with:
  who-to-greet: 'Mona the Octocat'


# Image preparation

- install protoc
```
$ apt install -y protobuf-compiler
$ protoc --version  # Ensure compiler version is 3+
```

- install protobuff -> go compiler
```
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

```


- install protoc-to-openapi
```
 go install github.com/google/gnostic/cmd/protoc-gen-openapi
```
- grp 
```
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
 
 
```
```
npm install @openapitools/openapi-generator-cli -g

```
