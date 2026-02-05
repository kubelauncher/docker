#!/bin/bash
set -e

KC_HOME="/opt/keycloak"

if [ "$1" = "start-dev" ] || [ "$1" = "start" ]; then
    exec "$KC_HOME/bin/kc.sh" "$@" $KC_EXTRA_ARGS
fi

exec "$@"
