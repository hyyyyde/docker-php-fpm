#!/bin/sh

set -eu

COMMAND_SUB=${1:-up}
PHPREDIS_VERSION=${2:-3.1.2}
export PHPREDIS_VERSION=$PHPREDIS_VERSION

case "$COMMAND_SUB" in
  up )
    docker-compose -f docker-compose.yml up -d --build
    ;;

  down )
    docker-compose -f docker-compose.yml down
    ;;

  * )
    exit
esac

docker-compose -f docker-compose.yml ps
