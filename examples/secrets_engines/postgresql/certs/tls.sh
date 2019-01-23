#!/bin/bash
set -e

cp /docker-entrypoint-initdb.d/server.{crt,key} "$PGDATA"
chown postgres:postgres "$PGDATA"/server.{crt,key}
chmod 0600 "$PGDATA"/server.key

