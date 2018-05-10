# source{d} CI

Simple build system to run continuous integration (CI) tasks on source{d} Go projects. Based on [GNU Make](https://www.gnu.org/software/make/).

## Features

* Build Go binaries.
* Run tests, optionally with coverage and [codecov](https://codecov.io/) integration.
* Automatic docker image upload on tag. It will upload the image to `$(DOCKER_ORG)/$(PROJECT)` on the given `DOCKER_REGISTRY`.
* Automatic upload of built binaries to GitHub releases on tag.
* Full [Travis CI] support on Linux and macOS.
* Partial Windows support on [Appveyor](https://www.appveyor.com/).
* Partial Linux support on [Drone](https://drone.io/).

## Getting Started

### Makefile

The main entrypoint for CI is a `Makefile` in the top-level directory of y our project. This `Makefile` requires minimal setup and delegates most logic to src-d/ci.

You will need to setup some variables to get basic functionality working:

* `PROJECT`: the project's name (mandatory).
* `COMMANDS`: packages and subpackages to be compiled as binaries (optional).
* `DOCKERFILES`: dockerfiles to be built (optional).

You can use the example [`Makefile`](https://github.com/src-d/ci/blob/v1/examples/basic/Makefile) as a template for new projects.

### Travis CI

Our main CI provider is Travis CI. It is used to run both Linux and macOS builds.

You can use the example [`.travis.yml`](https://github.com/src-d/ci/blob/v1/examples/basic/.travis.yml) as a template for new projects.

## Docker

In order to push Docker images, you need to setup credentials with the environment variables `DOCKER_USERNAME` and `DOCKER_REGISTRY`. When using Travis, you should define them as [secret environment variables](https://docs.travis-ci.com/user/environment-variables/#Defining-Variables-in-Repository-Settings).

You can customize the Docker registry and organization with the `DOCKER_REGISTRY` and `DOCKER_ORG`, which default to `docker.io` and `src-d` respectively.

## Tasks

### Tests packages

There are thee rules available for testing:

* `test`: regular execution of the tests
* `test-race` : execute the tests with the race detector enabled
* `test-coverage`: execute the tests and get coverage. This rule generates a `coverage.txt` and uploads it to codecov.io.

### Building packages

The rule `packages` creates the distribution packages, containing the command
line utilities defined by the `COMMANDS` compiled for the architectures and
OS defined by `PKG_OS` and `PKG_ARCH`.

The package filename is follows the following pattern: `<project>_<version>_<os>_<arch>.tar.gz`

### Docker build and push

The `docker-build` rule builds the dockerfiles defined by `DOCKERFILES`. Several
dockerfiles may be define in a project eg.:

If we have an application with two different docker images, we can achieve this
by creating two different docker files called `Dockerfile.server` and
`Dockerfile.client`.

```
DOCKERFILES = Dockerfile.server:$(PROJECT)-server Dockerfile.client:$(PROJECT)-client
```

The `DOCKERFILES` variable should be defined as list of dockerfile-path:image-name
pairs, for example `Dockerfile:my-image`.

The rule `docker-push` builds and pushes to the defined registry all the defined
docker images. The images are tagged with the current value of `VERSION`. If
`DOCKER_PUSH_LATEST` is provided with any value, a `latest` tag is created and
pushed too.

When writing your `Dockerfile` you can find the compiled binaries at
`$(BUILD_PATH)/bin` directory. E.g.: `ADD build/bin /bin`

## Notes

### Version calculation

The `VERSION` variable is calculated based on the current git commit, plus a
`-dirty` flag, if the worktree isn't clean. Example: `dev-01eda91-dirty`. If the
environment is Travis, the `TRAVIS_BRANCH` is used as `VERSION`. The variable is
set if it wasn't set previously.

### Custom build parameters

The `go build` commands supports several variables, which are easily
customizable to cover edge cases of complex builds.

* `LD_FLAGS`: used to define the LD_FLAGS provided to the go compiler it's preconfigured with some build info variables. Eg.: `LG_FLAGS += -extldflags "-static" -s -w`
* `GO_TAGS`: Tags to be used as `-tags` argument at `go build` and `go install`
* `GO_BUILD_ENV`: Envariamble variables used at the `go build` execution . E.g.: `GO_BUILD_ENV = CGO_ENABLED=0`

### Rule `no-changes-in-commit`

The `no-changes-in-commit` rule checks if files in the repository have changed.
Useful to detect non-commited generated code for projects based on `go generate`
or `gobindata`.

Example:

```
validate-commit: generate-assets no-changes-in-commit

generate-assets:
  yarn build
  go-bindata dist
```
