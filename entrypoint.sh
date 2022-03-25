#!/bin/sh -vlx
# Test locally:
# export GITHUB_WORKSPACE=/home/fedor/projects/acquire/video-service-api
# export INPUT_PROTO_SPEC_DIR_LOCATION=spec
# export INPUT_API_DIR_LOCATION=api
# export ROOT_DIR=/home/fedor/projects/acquire/api-processor

# docker run --rm --env INPUT_PROTO_SPEC_DIR_LOCATION --env INPUT_API_DIR_LOCATION -v /home/fedor/projects/acquire/video-service-api:/wsp  --env GITHUB_WORKSPACE=/wsp b9f63d1c38b0
# docker run -it --rm --entrypoint="/bin/bash" b9f63d1c38b0

export PATH=$PATH:/root/go/bin

echo "GITHUB_WORKSPACE:" $GITHUB_WORKSPACE  # input variables
echo "INPUT_PROTO_SPEC_DIR_LOCATION:" $INPUT_PROTO_SPEC_DIR_LOCATION  # input variables
echo "INPUT_API_DIR_LOCATION:" $INPUT_API_DIR_LOCATION  # input variables

ROOT_DIR=${ROOT_DIR-'/api-processor'}
PROTO_SPEC_DIR=$GITHUB_WORKSPACE/$INPUT_PROTO_SPEC_DIR_LOCATION
PROTO_SPEC_FILE=api.proto
ANNOTATION_PROTO_DIR=$ROOT_DIR/protos
OPEN_API_OUTPUT_DIR=$GITHUB_WORKSPACE/open-api
OPEN_API_SPEC_FILE=$OPEN_API_OUTPUT_DIR/openapi.yaml  
GO_OUTPUT_DIR=$GITHUB_WORKSPACE/go
GO_GRPC_OUTPUT_DIR=$GITHUB_WORKSPACE/go-rpc
JS_OUTPUT_DIR=$GITHUB_WORKSPACE/js-api

ls -al $PROTO_SPEC_DIR

rm -r -d -f $OPEN_API_OUTPUT_DIR $GO_OUTPUT_DIR $GO_GRPC_OUTPUT_DIR $JS_OUTPUT_DIR
mkdir -p $OPEN_API_OUTPUT_DIR $GO_OUTPUT_DIR $GO_GRPC_OUTPUT_DIR $JS_OUTPUT_DIR

# Open API
protoc $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR  --openapi_out=$OPEN_API_OUTPUT_DIR
# Go
protoc $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR --go_out=$GO_OUTPUT_DIR  --go_opt=paths=source_relative

#Go RPC
protoc  $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR --go_out=$GO_GRPC_OUTPUT_DIR --go_opt=paths=source_relative \
    --go-grpc_out=$GO_GRPC_OUTPUT_DIR --go-grpc_opt=paths=source_relative \

# JS
java -jar /root/openapi-generator-cli.jar generate -i $OPEN_API_SPEC_FILE -g typescript-axios -o $JS_OUTPUT_DIR
