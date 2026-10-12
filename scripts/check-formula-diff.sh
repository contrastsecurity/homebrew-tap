#!/usr/bin/env bash
# Fails unless the tap's only change is a contrast-cli version bump: the formula's one version line
# and four sha256 lines, and nothing else.
# Usage: check-formula-diff.sh <tap-dir> <base-rev> [<head-rev>]
#   With <head-rev>, checks the merge-base diff <base-rev>...<head-rev>.
#   Without it, checks the working tree, untracked files included, against <base-rev>.
set -euo pipefail

FORMULA=Formula/contrast-cli.rb

fail() {
  echo "::error::$1"
  shift
  printf '%s\n' "$@"
  exit 1
}

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
  echo "usage: $0 <tap-dir> <base-rev> [<head-rev>]" >&2
  exit 2
fi
cd "$1"
if [ $# -eq 3 ]; then
  range="$2...$3"
  untracked=""
  head_file="$(git show "$3:$FORMULA")"
else
  range="$2"
  untracked="$(git ls-files --others --exclude-standard)"
  head_file="$(cat "$FORMULA")"
fi

changed="$(git diff --no-renames --name-only "$range")"
summary="$(git diff --no-renames --summary "$range")"
if [ "$changed" != "$FORMULA" ] || [ -n "$summary" ] || [ -n "$untracked" ]; then
  fail "only the contents of $FORMULA may change, but the tap has:" "$changed" "$summary" "$untracked"
fi

diff="$(git diff --no-renames -U0 "$range" -- "$FORMULA")"
# Only lines after the first hunk header, so no content line can pass as a diff header
body="$(awk '/^@@/ { h = 1; next } h && /^[-+]/' <<<"$diff")"
bad="$(grep -vE '^[-+](  version "[0-9]+\.[0-9]+\.[0-9]+"|      sha256 "[0-9a-f]{64}")$' <<<"$body" || true)"
if [ -n "$bad" ]; then
  fail "lines other than version and sha256 changed:" "$bad"
fi

counts="$(grep -c '^-  version ' <<<"$body" || true) $(grep -c '^+  version ' <<<"$body" || true)"
counts+=" $(grep -c '^-      sha256 ' <<<"$body" || true) $(grep -c '^+      sha256 ' <<<"$body" || true)"
counts+=" $(grep -cE '^\s*version\s' <<<"$head_file" || true) $(grep -cE '^\s*sha256\s' <<<"$head_file" || true)"
if [ "$counts" != "1 1 4 4 1 4" ]; then
  fail "expected one version and four sha256 changes in a formula with one version and four sha256 lines, got [-version +version -sha256 +sha256 version sha256] = [$counts]"
fi
echo "$FORMULA changes only its version and sha256 lines"
