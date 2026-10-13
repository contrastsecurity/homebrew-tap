#!/usr/bin/env bash
# Runs scripts/check-formula-diff.sh on version bumps of the real formula, good and tampered,
# in both its working-tree and commit-range modes.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
check="$root/scripts/check-formula-diff.sh"
# contrast-cns keeps a byte-identical copy of the gate and pins the same hash
GATE_SHA256=652ab5bf291c03ad07d0bef7aecc5971d57031fbdccaba6ae77ab5017cc1a8b1
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0

after_version() { LINE="$1" perl -pi -e 's/^(  version .*)$/$1\n$ENV{LINE}/' Formula/contrast-cli.rb; }
edit() { perl -0pi -e "$1" Formula/contrast-cli.rb; }
commit() { git add -A && git -c user.name=t -c user.email=t@t commit -qm "$1"; }

# <name> <expected error fragment, empty to expect a pass> <mutation of the bumped formula>
#   [<mutation of the base before it is committed>] [<modes>] [<mutation after the head commit>]
run_case() {
  local name="$1" expected="$2" mutation="$3" pre="${4:-:}" modes="${5:-tree range}" post="${6:-:}"
  local mode dir base rc ok
  for mode in $modes; do
    dir="$(mktemp -d "$tmp/case.XXXXXX")"
    mkdir "$dir/Formula"
    cp "$root/Formula/contrast-cli.rb" "$dir/Formula/"
    (
      cd "$dir"
      git init -q .
      eval "$pre"
      commit base
      perl -pi -e 's/^  version "[^"]*"$/  version "9.9.9"/; s/^(      sha256 ")[0-9a-f]{64}/$1 . ("ab" x 32)/e' Formula/contrast-cli.rb
      eval "$mutation"
    )
    base="$(git -C "$dir" rev-parse HEAD)"
    if [ "$mode" = range ]; then
      (cd "$dir" && commit head && eval "$post")
      "$check" "$dir" "$base" HEAD >"$dir.log" 2>&1 && rc=0 || rc=$?
    else
      "$check" "$dir" "$base" >"$dir.log" 2>&1 && rc=0 || rc=$?
    fi
    if [ -z "$expected" ]; then
      [ "$rc" = 0 ] && ok=1 || ok=0
    else
      # A refusal must come from the expected gate, not from another gate or the script erroring out
      [ "$rc" = 1 ] && grep -qF "::error::" "$dir.log" && grep -qF -- "$expected" "$dir.log" && ok=1 || ok=0
    fi
    if [ "$ok" = 1 ]; then
      echo "ok   $name ($mode)"
    else
      echo "FAIL $name ($mode): exit $rc, expected ${expected:-a pass}"
      cat "$dir.log"
      failures=$((failures + 1))
    fi
  done
}

only="only the contents of"
lines="lines other than version and sha256 changed"
differs="differs beyond the version and sha256 values"
counts="expected one version and four sha256 changes"

run_case "good update" "" ":"
run_case "working tree differs from the committed head" "" ":" ":" range "after_version '  version \"9.9.8\"'"
run_case "'++ b/' content line" "$lines" "after_version '++ b/1 if false; system \"evil\"'"
run_case "invalid UTF-8 after a sha" "$lines" "edit 's/^(      sha256 \"[0-9a-f]{64}\")\$/\$1; system(\"id\") #\\xff/m'"
run_case "CRLF sha line" "$lines" "edit 's/^(      sha256 \"[0-9a-f]{64}\")\$/\$1\\r/m'"
run_case "trailing space" "$lines" "edit 's/^(      sha256 \"[0-9a-f]{64}\")\$/\$1 /m'"
run_case "trailing comment" "$lines" "edit 's/^(      sha256 \"[0-9a-f]{64}\")\$/\$1 # x/m'"
run_case "uppercase sha" "$lines" "edit 's/^(      sha256 \")ab/\$1AB/m'"
run_case "short sha" "$lines" "edit 's/^(      sha256 \")ab/\$1/m'"
run_case "leading-zero version" "$lines" "edit 's/^  version \"9.9.9\"/  version \"09.9.9\"/m'"
run_case "mangled install line" "$lines" "edit 's/\"_internal\"\$/\"_internal\", \"evil\"/m'"
run_case "missing final newline" "$lines" "edit 's/\\n\\z//'"
run_case "duplicate sha line" "$differs" "edit 's/^(      sha256 .*\\n)/\$1\$1/m'"
run_case "second version line" "$differs" "after_version '  version \"9.9.8\"'"
run_case "version moved into install" "$differs" \
  "edit 's/^(  version .*)\\n//m; s/^(  def install\\n)/\$1  version \"9.9.9\"\\n/m'"
run_case "sha moved to another block" "$differs" \
  "edit 's/^(      sha256 .*\\n)(    end\\n    on_intel do\\n)/\$2\$1/m'"
run_case "unchanged extra version line in the base" "$counts" ":" \
  "edit 's/^(  def install\\n)/\$1    version \"0.0.1\"\\n/m'"
run_case "unchanged extra sha line in the base" "$counts" ":" \
  "edit 's/^(  def install\\n)/\$1        sha256 \"$(printf 'cd%.0s' {1..32})\"\\n/m'"
run_case "mode change" "$only" "chmod +x Formula/contrast-cli.rb"
run_case "formula replaced by a symlink" "$only" \
  "mv Formula/contrast-cli.rb ../\$(basename \"\$PWD\").rb && ln -s ../../\$(basename \"\$PWD\").rb Formula/contrast-cli.rb"
run_case "formula deleted" "$only" "rm Formula/contrast-cli.rb"
run_case "extra file" "$only" "echo x > extra"

if command -v sha256sum >/dev/null; then
  gate_sha256="$(sha256sum "$check" | cut -d' ' -f1)"
else
  gate_sha256="$(shasum -a 256 "$check" | cut -d' ' -f1)"
fi
if [ "$gate_sha256" = "$GATE_SHA256" ]; then
  echo "ok   gate matches the pinned hash"
else
  echo "FAIL gate hash is $gate_sha256, pinned $GATE_SHA256: update the contrast-cns copy and both pins"
  failures=$((failures + 1))
fi

[ "$failures" -eq 0 ]
