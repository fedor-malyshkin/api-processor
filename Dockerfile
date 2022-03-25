# Container image that runs your code
FROM ghcr.io/fedor-malyshkin/api-processor:latest

RUN mkdir -p  /api-processor
COPY protos/ /api-processor/protos/

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
