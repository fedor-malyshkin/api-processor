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
GO_OUTPUT_DIR=$GITHUB_WORKSPACE/go/api
GO_GRPC_OUTPUT_DIR=$GITHUB_WORKSPACE/go-rpc/api
JS_OUTPUT_DIR=$GITHUB_WORKSPACE/js-api

rm -r -d -f $OPEN_API_OUTPUT_DIR $GO_OUTPUT_DIR $GO_GRPC_OUTPUT_DIR $JS_OUTPUT_DIR
mkdir -p $OPEN_API_OUTPUT_DIR $GO_OUTPUT_DIR $GO_GRPC_OUTPUT_DIR $JS_OUTPUT_DIR

root_dir=$GITHUB_WORKSPACE

# Go
cd $root_dir
if protoc $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR --go_out=$GO_OUTPUT_DIR  --go_opt=paths=source_relative; then
  cd $GO_OUTPUT_DIR
  go mod init "github.com/"$GITHUB_REPOSITORY"/go/api"
  go mod tidy
else
     exit $?
fi


#Go RPC
cd $root_dir
if protoc  $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR --go_out=$GO_GRPC_OUTPUT_DIR --go_opt=paths=source_relative \
    --go-grpc_out=$GO_GRPC_OUTPUT_DIR --go-grpc_opt=paths=source_relative; then
  cd $GO_GRPC_OUTPUT_DIR
  go mod init "github.com/"$GITHUB_REPOSITORY"/go-rpc/api"
  go mod tidy
else
     exit $?
fi


version=`cat $GITHUB_WORKSPACE/VERSION`

version=`cat $GITHUB_WORKSPACE/VERSION`
REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}
remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

set_version_and_save_to_file() {
  if [ "$branch" = "master" -o "$branch" = "main"  ] ; then
    version=`$PROCESSOR_DIR/semver.sh bump patch $version`
    echo $version > $GITHUB_WORKSPACE/VERSION
  fi
  if [ "$branch" = "develop" ] ; then
    version=`$PROCESSOR_DIR/semver.sh bump prerel dev. $version`
    echo $version > $GITHUB_WORKSPACE/VERSION
  fi
}

commit_and_tag_git()
{
  cd $root_dir
  git config user.email "api-processor@example.com"  && \
  git config user.name "API Processor"  && \
  git add $GO_GRPC_OUTPUT_DIR'/**' && \
  git add $GO_OUTPUT_DIR'/**' && \
  git add $JS_OUTPUT_DIR'/**' && \
  git commit -a -m "[API Processor] New API for version $version"  && \
  git tag "go/api/v$version"  && \
  git tag "go-rpc/api/v$version"
}

# !! increment if needed
set_version_and_save_to_file


# JS
if [ "$branch" = "develop" -o "$branch" = "master" -o "$branch" = "main" ] ; then
  cd $root_dir
  rm -r -d -f js-temp
  mkdir js-temp
  cd js-temp
  npm install -D @protobuf-ts/plugin
  if npx protoc $PROTO_SPEC_FILE -I$PROTO_SPEC_DIR -I$ANNOTATION_PROTO_DIR  --ts_opt generate_dependencies --ts_out $JS_OUTPUT_DIR; then
    cp $PROCESSOR_DIR/js/*  $JS_OUTPUT_DIR     && \
    sed -i "'s/##NAME##/@fedor-malyshkin/${GITHUB_REPOSITORY##*/}/'" $JS_OUTPUT_DIR/package.json    && \
    sed -i "'s/##VERSION##/$version/'" $JS_OUTPUT_DIR/package.json    && \
    npm install && npm run-script build   
  else
       exit $?
  fi
fi

if [ "$branch" = "develop" -o "$branch" = "master" -o "$branch" = "main" ] ; then
  cd $root_dir
  commit_and_tag_git
  git push  --tags --repo="${remote_repo}" origin HEAD
fi

# update VERSION in develop
if [ "$branch" = "master" -o "$branch" = "main"  ] ; then
  cd $root_dir
  git clean -d -f && \
  git fetch origin develop:refs/remotes/origin/develop  && \
  git checkout  develop && \
  echo $version > $GITHUB_WORKSPACE/VERSION && \
  git commit -a -m "[API Processor] New API for version $version" && \
  git push --tags --repo="${remote_repo}" origin HEAD && \
  git checkout  $branch  # to work with JS pacjages we generated before
fi

exit $?
