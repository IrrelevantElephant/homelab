#!/bin/sh

set -eu

install -d /tmp/forgejo/custom/conf
printf '%s\n' \
  'APP_NAME = Forgejo' \
  'RUN_MODE = prod' \
  'WORK_PATH = /tmp/forgejo' \
  '[database]' \
  'DB_TYPE = postgres' \
  'HOST = forgejo-postgres-rw:5432' \
  'NAME = forgejo' \
  "USER = ${DATABASE_USER}" \
  "PASSWD = ${DATABASE_PASSWORD}" \
  'SSL_MODE = disable' \
  '[security]' \
  'INSTALL_LOCK = true' \
  > /tmp/forgejo/custom/conf/app.ini

forgejo \
  --work-path /tmp/forgejo \
  --config /tmp/forgejo/custom/conf/app.ini \
  forgejo-cli actions register \
  --name kubernetes \
  --labels docker,ubuntu-latest,self-hosted \
  --secret-file /registration/secret
