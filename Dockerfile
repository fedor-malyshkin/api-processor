# Container image that runs your code
# FROM ubuntu:20.04
FROM debian:bookworm

RUN apt-get update && apt -y --no-install-recommends install golang-go protobuf-compiler ca-certificates openssl wget curl npm 

# nodejs
# RUN curl -o- 'https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh' | bash

# ENV NVM_DIR=/root/.nvm
# ENV NODE_VERSION 14.18.0

# RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# RUN source $NVM_DIR/nvm.sh \
#     && nvm install $NODE_VERSION \
#     && nvm alias default $NODE_VERSION \
#    && nvm use default


RUN mkdir -p  /api-processor
COPY protos/ /api-processor/ 

# install
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest  && \
go install github.com/google/gnostic/cmd/protoc-gen-openapi@latest  && \
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest  && \
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest  && \
npm install @openapitools/openapi-generator-cli -g


# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
