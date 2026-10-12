#!/usr/bin/env bash
# Runs scripts/check-formula-diff.sh on version bumps of the real formula, good and tampered,
# in both its working-tree and commit-range modes.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
check="$root/scripts/check-formula-diff.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0

after_version() { perl -pi -e "s/^(  version .*)\$/\$1\n$1/" Formula/contrast-cli.rb; }

run_case() {  # <name> <expected exit> <mutation>
  local name="$1" expected="$2" mutation="$3" mode dir base rc
  for mode in tree range; do
    dir="$(mktemp -d "$tmp/case.XXXXXX")"
    mkdir "$dir/Formula"
    cp "$root/Formula/contrast-cli.rb" "$dir/Formula/"
    (
      cd "$dir"
      git init -q .
      git add -A
      git -c user.name=t -c user.email=t@t commit -qm base
      perl -pi -e 's/^  version "[^"]*"$/  version "9.9.9"/; s/^(      sha256 ")[0-9a-f]{64}/$1 . ("ab" x 32)/e' Formula/contrast-cli.rb
      eval "$mutation"
    )
    base="$(git -C "$dir" rev-parse HEAD)"
    if [ "$mode" = range ]; then
      git -C "$dir" add -A
      git -C "$dir" -c user.name=t -c user.email=t@t commit -qm head
      "$check" "$dir" "$base" HEAD >"$dir.log" 2>&1 && rc=0 || rc=$?
    else
      "$check" "$dir" "$base" >"$dir.log" 2>&1 && rc=0 || rc=$?
    fi
    # A refusal must come from a gate, not from the script or git erroring out
    if [ "$rc" = "$expected" ] && { [ "$rc" = 0 ] || grep -q '::error::' "$dir.log"; }; then
      echo "ok   $name ($mode)"
    else
      echo "FAIL $name ($mode): exit $rc, expected $expected"
      cat "$dir.log"
      failures=$((failures + 1))
    fi
  done
}

run_case "good update" 0 ":"
run_case "'++ b/' content line" 1 "after_version '++ b\/1 if false; system \"evil\"'"
run_case "duplicate sha line" 1 "perl -0pi -e 's/^(      sha256 .*\n)/\$1\$1/m' Formula/contrast-cli.rb"
run_case "second version line" 1 "after_version '  version \"9.9.8\"'"
run_case "mangled install line" 1 "perl -pi -e 's/\"_internal\"\$/\"_internal\", \"evil\"/' Formula/contrast-cli.rb"
run_case "mode change" 1 "chmod +x Formula/contrast-cli.rb"
run_case "extra file" 1 "echo x > extra"

[ "$failures" -eq 0 ]
