#!/usr/bin/env bash
# Runs the provenance workflow's Artifactory checks against canned responses: a curl on PATH that
# serves local files, and a sleep that returns at once.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0
BASE_URL=https://artifactory.test/contrast-cli
PLATFORMS=(darwin-arm64 darwin-amd64 linux-arm64 linux-amd64)

# Serves <url> from $SERVE/<path after BASE_URL>, the headers file with -I. The n-th fetch of a file
# serves <file>.<n> when that exists, so a test can change a response between retries.
mkdir "$tmp/bin"
cat >"$tmp/bin/curl" <<'EOF'
#!/usr/bin/env bash
headers="" url=""
for arg in "$@"; do
  case "$arg" in
    -*I*) headers=1 ;;
    https://*) url="$arg" ;;
  esac
done
file="$SERVE/${url#https://artifactory.test/contrast-cli/}"
[ -n "$headers" ] && file="$file.headers"
count_file="$SERVE/.count-$(printf '%s' "$file" | tr '/' '_')"
n=$(($(cat "$count_file" 2>/dev/null || echo 0) + 1))
echo "$n" >"$count_file"
[ -f "$file.$n" ] && file="$file.$n"
[ -f "$file" ] || exit 22
cat "$file"
EOF
printf '#!/bin/sh\n' >"$tmp/bin/sleep"
chmod +x "$tmp/bin/curl" "$tmp/bin/sleep"

# The real formula with <version>, and urls that name the contrast-cli archives whichever names
# the formula currently uses
formula_at() {  # <dir> <version>
  VERSION="$2" perl -pe 's/^  version ".*"$/  version "$ENV{VERSION}"/; s{/contrast-cns([-\/])}{/contrast-cli$1}' \
    "$root/Formula/contrast-cli.rb" >"$1/formula.rb"
}

# <name> <expected exit> <expected output fragment> <script and args...>, run in $dir
run() {
  local name="$1" expected="$2" fragment="$3" rc
  shift 3
  PATH="$tmp/bin:$PATH" SERVE="$dir/serve" GITHUB_OUTPUT="$dir/output" "$@" >"$dir/log" 2>&1 && rc=0 || rc=$?
  if [ "$rc" = "$expected" ] && grep -qF -- "$fragment" "$dir/log"; then
    echo "ok   $name"
  else
    echo "FAIL $name: exit $rc, expected $expected with '$fragment'"
    cat "$dir/log"
    failures=$((failures + 1))
  fi
}

new_case() {
  dir="$(mktemp -d "$tmp/case.XXXXXX")"
  mkdir -p "$dir/serve"
  : >"$dir/output"
}

fetches() { cat "$dir/serve/.count-$(printf '%s' "$dir/serve/latest-version.txt" | tr '/' '_')"; }

# <name> <formula version> <expected exit> <expected fetches> <served versions, in fetch order>
latest_case() {
  local name="$1" version="$2" expected="$3" want_fetches="$4" n=0 served fragment
  shift 4
  new_case
  formula_at "$dir" "$version"
  for served in "$@"; do
    n=$((n + 1))
    if [ "$served" != missing ]; then echo "VERSION=$served" >"$dir/serve/latest-version.txt.$n"; fi
  done
  # Later fetches repeat the last response
  [ "$served" = missing ] || echo "VERSION=$served" >"$dir/serve/latest-version.txt"
  if [ "$expected" = 0 ]; then fragment="is the latest published release"; else fragment="::error::"; fi
  run "$name" "$expected" "$fragment" "$root/scripts/check-latest-version.sh" "$dir/formula.rb" "$BASE_URL"
  if [ "$(fetches)" != "$want_fetches" ]; then
    echo "FAIL $name: fetched latest-version.txt $(fetches) times, expected $want_fetches"
    failures=$((failures + 1))
  fi
  if [ "$expected" = 0 ] && ! grep -qx "version=$version" "$dir/output"; then
    echo "FAIL $name: no version=$version output"
    failures=$((failures + 1))
  fi
}

latest_case "latest on the first read" 1.2.3 0 1 1.2.3
latest_case "stale latest that catches up" 1.2.3 0 3 1.2.2 1.2.2 1.2.3
latest_case "stale latest that never catches up" 1.2.3 1 6 1.2.2
latest_case "latest newer than the formula" 1.2.3 1 1 1.2.4
latest_case "0.1.10 is newer than 0.1.9" 0.1.10 1 6 0.1.9
latest_case "latest-version.txt unreachable" 1.2.3 1 6 missing

# <dir> <platform> <status lines and headers, one per line>
serve_headers() {
  mkdir -p "$1/serve/9.9.9"
  printf '%s\r\n' "${@:3}" >"$1/serve/9.9.9/contrast-cli-$2.tar.gz.headers"
}

# Serves a final 200 carrying each archive's formula sha, in the case Artifactory uses
serve_formula_shas() {
  local platform sum
  for platform in "${PLATFORMS[@]}"; do
    sum="$(ARCHIVE="contrast-cli-$platform.tar.gz" perl -0ne \
      'print $1 if m{/\Q$ENV{ARCHIVE}\E"\n      sha256 "([0-9a-f]{64})"$}m' "$dir/formula.rb")"
    serve_headers "$dir" "$platform" "HTTP/1.1 200 OK" "X-Checksum-Sha256: $sum" ""
  done
}

checksums() {  # <name> <expected exit> <expected fragment>
  run "$1" "$2" "$3" "$root/scripts/check-artifactory-checksums.sh" "$dir/formula.rb" "$BASE_URL" 9.9.9
}

new_case
formula_at "$dir" 9.9.9
serve_formula_shas
checksums "checksums match" 0 "contrast-cli-linux-amd64.tar.gz"

new_case
formula_at "$dir" 9.9.9
serve_formula_shas
sum="$(grep -m1 -oE '[0-9a-f]{64}' "$dir/formula.rb")"
serve_headers "$dir" darwin-arm64 "HTTP/1.1 302 Found" "Location: https://cdn.test/x" "" \
  "HTTP/2 200" "x-checksum-sha256: $(tr 'a-f' 'A-F' <<<"$sum")" ""
checksums "checksum on the final response after a redirect, any case" 0 "contrast-cli-darwin-arm64.tar.gz $sum"

new_case
formula_at "$dir" 9.9.9
serve_formula_shas
serve_headers "$dir" darwin-arm64 "HTTP/1.1 302 Found" "X-Checksum-Sha256: $sum" "" "HTTP/2 200" ""
checksums "checksum only on the redirect" 1 "Artifactory serves ''"

new_case
formula_at "$dir" 9.9.9
serve_formula_shas
serve_headers "$dir" linux-arm64 "HTTP/1.1 200 OK" "X-Checksum-Sha256: $(printf 'ef%.0s' {1..32})" ""
checksums "checksum mismatch" 1 "::error::contrast-cli-linux-arm64.tar.gz: formula has"

new_case
formula_at "$dir" 9.9.9
serve_formula_shas
command rm "$dir/serve/9.9.9/contrast-cli-linux-amd64.tar.gz.headers"
checksums "headers unreachable" 1 "could not fetch contrast-cli-linux-amd64.tar.gz headers"

new_case
formula_at "$dir" 9.9.9
serve_formula_shas
perl -pi -e 's/^(      sha256 "[0-9a-f]{64}")$/$1; system("id")/ if $. == 11' "$dir/formula.rb"
checksums "code after a sha" 1 "contrast-cli-darwin-arm64.tar.gz: formula has ''"

new_case
formula_at "$dir" 9.9.9
serve_formula_shas
perl -pi -e 's{/contrast-cli-darwin-arm64}{/x-contrast-cli-darwin-arm64}' "$dir/formula.rb"
checksums "url naming another archive" 1 "contrast-cli-darwin-arm64.tar.gz: formula has ''"

[ "$failures" -eq 0 ]
