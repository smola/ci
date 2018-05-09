#!/bin/bash
set -e

_cmd() {
    echo "$@"
    "$@"
}

if [[ -z ${RABBITMQ_VERSION} ]]; then
	echo "RABBITMQ_VERSION not set, skipping"
	exit 0
fi

echo "Installing whatever RabbitMQ version is available (ignore ${RABBITMQ_VERSION})"

if [[ ! -z ${TRAVIS} ]]; then
	case "${TRAVIS_OS_NAME}" in
		linux)
			_cmd sudo service rabbitmq-server start
            ;;
		osx)
            _cmd brew install rabbitmq
            export PATH="${PATH}:/usr/local/sbin"
            _cmd sudo rabbitmq-server -detached
            ;;
		*)
			echo "Unrecognized TRAVIS_OS_NAME: ${TRAVIS_OS_NAME}"
			exit 1
            ;;
	esac
	exit 0
fi

if [[ ! -z ${APPVEYOR} ]]; then
    # Only dependency is Erlang, which is already installed in Appveyor.
    export PATH="/c/Program Files/erl9.2/bin:/c/ProgramData/chocolatey/bin:${PATH}"
	_cmd choco install rabbitmq --ignoredependencies -y
    # Give some time to RabbitMQ initialization.
    sleep 2
    exit 0
fi

echo "Unrecognized CI (not Travis or Appveyor)"
exit 1