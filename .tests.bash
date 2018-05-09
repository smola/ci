#!/bin/bash
set -e

MAKE=make
if [[ ! -z ${APPVEYOR} ]]; then
	MAKE=mingw32-make
fi

EXAMPLES="examples/basic"

MAKE=make
if [[ ! -z ${APPVEYOR} ]]; then
	MAKE=mingw32-make
fi

for example in ${EXAMPLES} ; do
	echo "Running $example"

	mkdir -p ${example}/.ci
	cp Makefile.main ${example}/.ci/
	pushd $example &> /dev/null

	"${MAKE}" dependencies

	"${MAKE}" test

	"${MAKE}" test-coverage

	"${MAKE}" packages

	popd &> /dev/null
done
