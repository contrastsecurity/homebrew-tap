#!/usr/bin/env bash
# Fails unless the formula's version is the latest release, as Artifactory's latest-version.txt says.
# Writes "version=<x.y.z>" to $GITHUB_OUTPUT when it is set.
# Usage: check-latest-version.sh <formula> <base-url>
set -euo pipefail
export LC_ALL=C

ATTEMPTS=6

if [ $# -ne 2 ]; then
  echo "usage: $0 <formula> <base-url>" >&2
  exit 2
fi
formula="$1" base_url="$2"

version="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$formula")"
for attempt in $(seq "$ATTEMPTS"); do
  latest="$(curl -fsSL --connect-timeout 10 --max-time 30 --retry 5 --retry-delay 10 --retry-all-errors \
    "$base_url/latest-version.txt" | sed -n 's/^VERSION=//p' | tr -d '[:space:]' || true)"
  # The PR can open moments after promotion, before the CDN serves the new latest-version.txt
  if [ "$version" = "$latest" ] || [ "$attempt" -eq "$ATTEMPTS" ] \
    || [ "$(printf '%s\n%s\n' "$latest" "$version" | sort -V | tail -1)" != "$version" ]; then
    break
  fi
  echo "latest-version.txt says '${latest}', retrying in 20s"
  sleep 20
done
if [ -z "$version" ] || [ "$version" != "$latest" ]; then
  echo "::error::formula version '${version}' is not the latest published release '${latest}'"
  exit 1
fi
echo "${version} is the latest published release"
if [ -n "${GITHUB_OUTPUT:-}" ]; then echo "version=${version}" >>"$GITHUB_OUTPUT"; fi
