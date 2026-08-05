#!/bin/sh

set -eu

secret="$(tr -d '\r\n' < /registration/secret)"
if ! printf '%s' "${secret}" | grep -Eq '^[0-9a-fA-F]{40}$'; then
  echo 'runner registration secret must contain exactly 40 hexadecimal characters' >&2
  exit 1
fi

identifier="$(printf '%s' "${secret}" | cut -c1-16)"
encoded="$(printf '%s' "${identifier}" | od -An -tx1 | tr -d ' \n')"
uuid="$(printf '%s-%s-%s-%s-%s' \
  "$(printf '%s' "${encoded}" | cut -c1-8)" \
  "$(printf '%s' "${encoded}" | cut -c9-12)" \
  "$(printf '%s' "${encoded}" | cut -c13-16)" \
  "$(printf '%s' "${encoded}" | cut -c17-20)" \
  "$(printf '%s' "${encoded}" | cut -c21-32)")"

cp /config/config.yaml /data/config.yaml
printf '%s\n' \
  '' \
  'server:' \
  '  connections:' \
  '    forgejo:' \
  '      url: http://forgejo:3000/' \
  "      uuid: ${uuid}" \
  '      token_url: file:/registration/secret' \
  >> /data/config.yaml
