#!/usr/bin/env bash
# Updates Formula/contrast-cli.rb to the latest contrast-cli release published in Artifactory.
# Writes "version=<x.y.z>" and "updated=<true|false>" to $GITHUB_OUTPUT when it is set.
set -euo pipefail

BASE_URL="https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cns"
PLATFORMS=(darwin-arm64 darwin-amd64 linux-arm64 linux-amd64)
FORMULA="$(cd "$(dirname "$0")/.." && pwd)/Formula/contrast-cli.rb"

output() {
  echo "$1"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then echo "$1" >> "$GITHUB_OUTPUT"; fi
}

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

latest=$(curl -fsSL "$BASE_URL/latest-version.txt" | sed -n 's/^VERSION=//p' | tr -d '[:space:]')
current=$(sed -n 's/^  version "\(.*\)"$/\1/p' "$FORMULA")

if [[ ! "$latest" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Unexpected latest version: '$latest'" >&2
  exit 1
fi

newest=$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -1)
if [[ "$latest" == "$current" || "$newest" != "$latest" ]]; then
  echo "contrast-cli is up to date ($current, latest published $latest)"
  output "updated=false"
  exit 0
fi

echo "Updating contrast-cli from $current to $latest"
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

for platform in "${PLATFORMS[@]}"; do
  archive="contrast-cns-$platform.tar.gz"
  curl -fsSL -o "$workdir/$archive" "$BASE_URL/$latest/$archive"
  # Sanity check that the bundle still has the layout the formula installs
  tar -tzf "$workdir/$archive" | grep -qx "contrast-cns-$platform/contrast-cli" \
    || { echo "$archive is missing contrast-cli" >&2; exit 1; }
  tar -tzf "$workdir/$archive" | grep -q "^contrast-cns-$platform/_internal/" \
    || { echo "$archive is missing _internal/" >&2; exit 1; }
  sum=$(sha256 "$workdir/$archive")
  echo "  $archive $sum"
  ARCHIVE="$archive" SUM="$sum" perl -0pi -e \
    's/(\Q$ENV{ARCHIVE}\E"\n\s*sha256 ")[0-9a-f]{64}/${1}$ENV{SUM}/ or die "no sha256 for $ENV{ARCHIVE}\n"' \
    "$FORMULA"
done

VERSION="$latest" perl -pi -e 's/^  version "[^"]*"$/  version "$ENV{VERSION}"/' "$FORMULA"

output "version=$latest"
output "updated=true"
