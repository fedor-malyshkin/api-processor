# Container image that runs your code
# FROM ubuntu:20.04
FROM debian:bookworm

RUN apt-get update && apt -y --no-install-recommends install golang-go protobuf-compiler libprotobuf-dev ca-certificates openssl wget curl default-jre

RUN mkdir -p  /api-processor
COPY protos/ /api-processor/protos/

# install
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest  && \
go install github.com/google/gnostic/cmd/protoc-gen-openapi@latest  && \
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest  && \
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

RUN wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/5.3.0/openapi-generator-cli-5.3.0.jar -O /root/openapi-generator-cli.jar

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
