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

**NB:** the processor is looking for `api.proto` / `openapi.yml` files ONLY.

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

## Workflow inside
An important thing here is a `VERSION` file that lies inside API project's file. It keeps
a string of form `1.2.3` or something similar for `master`, and
`1.2.3-beta15` for `develop`.

When you set up the processor as shown in the snippet you should stick to the usage of several branches:
- `develop` - you merge here all your personal branches, when you do it the prerelease mark will be updated in the git:
`1.2.3-beta15` -> `1.2.3-beta16` and the new tag `1.2.3-beta16` will be created.
- `master/main` - the main branch where source of truth lies,
you should mergge here all you changes from `develop`. In this case `VERSION`
will be updated to release stat with patch pat increased: `1.2.3-beta15` -> `1.2.4`.
The tag with this value will be created and the same update will be done in `develop` brunch.
- `any other branches` - any of your personal branch


## Image preparation
You can look at base image and how it was created here: [base docker image](Dockerfile-base)

## Useful Links:
- https://github.com/fsaintjacques/semver-tool
- [Creating actions](https://docs.github.com/en/actions/creating-actions)
- [GitHub Actions](https://docs.github.com/en/actions)