#!/usr/bin/env bash
# Fails unless the tap's only change is a contrast-cli version bump: the values of the formula's one
# version line and four sha256 lines change in place, and nothing else changes.
# Usage: check-formula-diff.sh <tap-dir> <base-rev> [<head-rev>]
#   With <head-rev>, checks the merge-base diff <base-rev>...<head-rev>.
#   Without it, checks the working tree, untracked files included, against <base-rev>.
# homebrew-tap (scripts/) and contrast-cns (.github/scripts/) each keep a byte-identical copy, and each
# repo's tests pin its sha256. Change both copies and both pins together.
set -euo pipefail
# Byte semantics, so no tool treats a line with invalid UTF-8 as binary and skips it
export LC_ALL=C

FORMULA=Formula/contrast-cli.rb
VERSION_LINE='  version "(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"'
SHA_LINE='      sha256 "[0-9a-f]{64}"'

fail() {
  echo "::error::$1"
  shift
  printf '%s\n' "$@"
  exit 1
}

# Blanks the values of well-formed version and sha256 lines, leaving every other byte as is
mask() {
  sed -E "s/^$VERSION_LINE\$/  version \"X\"/; s/^$SHA_LINE\$/      sha256 \"X\"/" "$1"
}

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
  echo "usage: $0 <tap-dir> <base-rev> [<head-rev>]" >&2
  exit 2
fi
cd "$1"
if [ $# -eq 3 ]; then
  range="$2...$3"
  base_rev="$(git merge-base "$2" "$3")"
  head_rev="$3"
  untracked=""
else
  range="$2"
  base_rev="$2"
  head_rev=""
  untracked="$(git ls-files --others --exclude-standard)"
fi

changed="$(git diff --no-renames --name-only "$range")"
summary="$(git diff --no-renames --summary "$range")"
if [ "$changed" != "$FORMULA" ] || [ -n "$summary" ] || [ -n "$untracked" ]; then
  fail "only the contents of $FORMULA may change, but the tap has:" "$changed" "$summary" "$untracked"
fi

diff="$(git diff --no-renames -U0 "$range" -- "$FORMULA")"
# Only lines after the first hunk header, so no content line can pass as a diff header
body="$(awk '/^@@/ { h = 1; next } h && /^[-+]/' <<<"$diff")"
bad="$(grep -avE "^[-+]($VERSION_LINE|$SHA_LINE)\$" <<<"$body" || true)"
if [ -n "$bad" ]; then
  fail "lines other than version and sha256 changed:" "$bad"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git show "$base_rev:$FORMULA" >"$tmp/base"
if [ -n "$head_rev" ]; then
  git show "$head_rev:$FORMULA" >"$tmp/head"
else
  cp "$FORMULA" "$tmp/head"
fi
mask "$tmp/base" >"$tmp/base.masked"
mask "$tmp/head" >"$tmp/head.masked"
if ! cmp -s "$tmp/base.masked" "$tmp/head.masked"; then
  fail "the formula differs beyond the version and sha256 values:" \
    "$(diff "$tmp/base.masked" "$tmp/head.masked" || true)"
fi

counts="$(grep -ac '^-  version ' <<<"$body" || true) $(grep -ac '^+  version ' <<<"$body" || true)"
counts+=" $(grep -ac '^-      sha256 ' <<<"$body" || true) $(grep -ac '^+      sha256 ' <<<"$body" || true)"
counts+=" $(grep -acE '^[[:space:]]*version[[:space:]]' "$tmp/head" || true)"
counts+=" $(grep -acE '^[[:space:]]*sha256[[:space:]]' "$tmp/head" || true)"
if [ "$counts" != "1 1 4 4 1 4" ]; then
  fail "expected one version and four sha256 changes in a formula with one version and four sha256 lines, got [-version +version -sha256 +sha256 version sha256] = [$counts]"
fi
echo "$FORMULA changes only its version and sha256 lines"
