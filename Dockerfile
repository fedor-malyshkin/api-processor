# Container image that runs your code
FROM ghcr.io/fedor-malyshkin/api-processor:latest

RUN mkdir -p  /api-processor
COPY protos/ /api-processor/protos/
COPY js/ /api-processor/js/

COPY semver.sh /api-processor/
RUN chmod +x /api-processor/semver.sh

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
