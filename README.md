# API processor Docker Image

This action  does:
- generates Go stubs from protobuf specifications
- _generates OpenAPI specification from protobuf specifications_
- _generate JS stubs from OpenAPI specification_

## Inputs

### `proto_spec_dir_location`
- **Optional**
- Description:
- Default value: the dir with protobuf/Open API specifications.

NB: the processor is looking for `api.proto` / `openapi.yml` files.

## Example usage

```yaml
name: api-generate

on: [ push ]

jobs:
  build-test:
    runs-on: ubuntu-18.04
    steps:
      - name: src-checkout  # here we check out our source dir
        uses: actions/checkout@v2
      - name: run-api-processor # here we use the processor
        uses: fedor-malyshkin/api-processor@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

# Image preparation
You can look at base image and how it was created here: [base docker image](Dockerfile-base)


Links:
- https://github.com/fsaintjacques/semver-tool
- 