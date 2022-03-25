#!/bin/sh -vlx
# Test locally:
# export GITHUB_WORKSPACE=/home/fedor/projects/acquire/video-service-api
# export INPUT_PROTO_SPEC_DIR_LOCATION=spec
# export INPUT_API_DIR_LOCATION=api
# export GITHUB_REPOSITORY=api
# export GITHUB_REF=refs/heads/feature-branch-1
# export PROCESSOR_DIR=/home/fedor/projects/acquire/api-processor

# docker run --rm --env INPUT_PROTO_SPEC_DIR_LOCATION  -v /home/fedor/projects/acquire/video-service-api:/wsp  --env GITHUB_WORKSPACE=/wsp --env GITHUB_REPOSITORY --env GITHUB_REF b9f63d1c38b0
# docker run -it --rm --entrypoint="/bin/bash" b9f63d1c38b0

export PATH=$PATH:/root/go/bin

echo "GITHUB_WORKSPACE:" $GITHUB_WORKSPACE  # input variables
echo "INPUT_PROTO_SPEC_DIR_LOCATION:" $INPUT_PROTO_SPEC_DIR_LOCATION  # input variables

branch=${GITHUB_REF##*/}
PROCESSOR_DIR=${PROCESSOR_DIR-'/api-processor'}
PROTO_SPEC_DIR=$GITHUB_WORKSPACE/$INPUT_PROTO_SPEC_DIR_LOCATION
PROTO_SPEC_FILE=api.proto
ANNOTATION_PROTO_DIR=$PROCESSOR_DIR/protos
OPEN_API_OUTPUT_DIR=$GITHUB_WORKSPACE/open-api
OPEN_API_SPEC_FILE=$OPEN_API_OUTPUT_DIR/openapi.yaml  
GO_OUTPUT_DIR=$GITHUB_WORKSPACE/go
GO_GRPC_OUTPUT_DIR=$GITHUB_WORKSPACE/go-rpc
JS_OUTPUT_DIR=$GITHUB_WORKSPACE/js-api

rm -r -d -f $OPEN_API_OUTPUT_DIR $GO_OUTPUT_DIR $GO_GRPC_OUTPUT_DIR $JS_OUTPUT_DIR
mkdir -p $OPEN_API_OUTPUT_DIR $GO_OUTPUT_DIR $GO_GRPC_OUTPUT_DIR $JS_OUTPUT_DIR

root_dir=$PWD
# Open API
cd $root_dir
if protoc $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR  --openapi_out=$OPEN_API_OUTPUT_DIR; then
  # do nothing
  cd $root_dir
else
     exit $?
fi


# Go
cd $root_dir
if protoc $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR --go_out=$GO_OUTPUT_DIR  --go_opt=paths=source_relative; then
  cd $GO_OUTPUT_DIR
  go mod init "github.com/"$GITHUB_REPOSITORY"/go"
  go mod tidy
else
     exit $?
fi


#Go RPC
cd $root_dir
if protoc  $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR --go_out=$GO_GRPC_OUTPUT_DIR --go_opt=paths=source_relative \
    --go-grpc_out=$GO_GRPC_OUTPUT_DIR --go-grpc_opt=paths=source_relative; then
  cd $GO_GRPC_OUTPUT_DIR
  go mod init "github.com/"$GITHUB_REPOSITORY"/go-rpc"
  go mod tidy
else
     exit $?
fi

# JS
cd $root_dir
if java -jar $PROCESSOR_DIR/openapi-generator-cli.jar generate -i $OPEN_API_SPEC_FILE -g typescript-axios -o $JS_OUTPUT_DIR; then
  cd $JS_OUTPUT_DIR
  # do smth with npm
else
     exit $?
fi


cd $root_dir
work_with_git=true
# create branche
if [ "$branch" = "master" -o "$branch" = "main" ] ; then
  echo "master/main!!!"
  work_with_git=false
  cd $root_dir
fi

version=`cat $GITHUB_WORKSPACE/VERSION`
REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}
remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

if [ "$work_with_git" = "true"  ]; then

  if [ "$branch" = "develop"  ] ; then
    cd $root_dir
    version=`$PROCESSOR_DIR/semver.sh bump prerel beta. $version`
    echo $version > $GITHUB_WORKSPACE/VERSION
    git add -A
    git commit -a -m "[API Processor] New API for version $version"
    git tag $version
    git push "${remote_repo}"  --tags
  fi

  if [ "$branch" = "master" -o "$branch" = "main"  ] ; then
    cd $root_dir
    version=`$PROCESSOR_DIR/semver.sh bump patch $version`
    echo $version > $GITHUB_WORKSPACE/VERSION
    git add -A
    git commit -a -m "[API Processor] New API for version $version"
    git tag $version
    git push "${remote_repo}"  --tags
  fi

fi
