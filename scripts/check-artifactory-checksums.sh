#!/usr/bin/env bash
# Fails unless each archive's sha256 in the formula equals the X-Checksum-Sha256 Artifactory serves
# for that archive at <version>.
# Usage: check-artifactory-checksums.sh <formula> <base-url> <version>
set -euo pipefail
export LC_ALL=C

if [ $# -ne 3 ]; then
  echo "usage: $0 <formula> <base-url> <version>" >&2
  exit 2
fi
formula="$1" base_url="$2" version="$3"

failed=0
for platform in darwin-arm64 darwin-amd64 linux-arm64 linux-amd64; do
  archive="contrast-cli-${platform}.tar.gz"
  # Anchored to the url's last path segment and the whole sha line, so nothing else can match
  formula_sum="$(ARCHIVE="$archive" perl -0ne \
    'print $1 if m{/\Q$ENV{ARCHIVE}\E"\n      sha256 "([0-9a-f]{64})"$}m' "$formula")"
  if ! headers="$(curl -fsSIL --connect-timeout 10 --max-time 30 --retry 5 --retry-delay 10 --retry-all-errors \
    "$base_url/$version/$archive")"; then
    echo "::error::could not fetch ${archive} headers from Artifactory"
    failed=1
    continue
  fi
  # -L prints a header block per response, so keep only the final response's checksum
  served_sum="$(tr -d '\r' <<<"$headers" | awk -F': ' '
    /^HTTP\// { sum = "" }
    tolower($1) == "x-checksum-sha256" { sum = tolower($2) }
    END { print sum }')"
  if [ -z "$formula_sum" ] || [ "$formula_sum" != "$served_sum" ]; then
    echo "::error::${archive}: formula has '${formula_sum}', Artifactory serves '${served_sum}'"
    failed=1
  else
    echo "${archive} ${formula_sum}"
  fi
done
exit "$failed"
