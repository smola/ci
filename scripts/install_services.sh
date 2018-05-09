#!/bin/bash
set -e

cd "$(dirname "$0")"

if [[ ! -z ${POSTGRESQL_VERSION} ]]; then
	./install_postgresql.sh
fi

if [[ ! -z ${RABBITMQ_VERSION} ]]; then
	./install_rabbitmq.sh
fi

exit 0