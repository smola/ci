#!/bin/bash
set -e

_cmd() {
    echo "$@"
    "$@"
}

if [[ -z ${POSTGRESQL_VERSION} ]]; then
	echo "POSTGRESQL_VERSION not set, skipping"
	exit 0
fi

echo "Installing PostgreSQL ${POSTGRESQL_VERSION}"

if [[ ! -z ${TRAVIS} ]]; then
	case "${TRAVIS_OS_NAME}" in
		linux)
			_cmd sudo service postgresql stop
			_cmd sudo service postgresql start ${POSTGRESQL_VERSION}
			;;
		osx)
			# https://github.com/travis-ci/travis-ci/issues/1875
			_cmd rm -rf /usr/local/var/postgres
			_cmd initdb /usr/local/var/postgres
			_cmd pg_ctl -D /usr/local/var/postgres start
			sleep 1
			_cmd createuser -s -p 5432 postgres
			;;
		*)
			echo "Unrecognized TRAVIS_OS_NAME: ${TRAVIS_OS_NAME}"
			exit 1
			;;
	esac
	exit 0
fi

if [[ ! -z ${APPVEYOR} ]]; then
	if [[ $(uname -a) =~ x86_64 ]]; then
		net start postgresql-x64-${POSTGRESQL_VERSION}
	else
		echo "PostgreSQL is currently supported only on x86_64"
		exit 1
	fi
	
	exit 0
fi

echo "Unrecognized CI (not Travis or Appveyor)"
exit 1