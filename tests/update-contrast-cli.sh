#!/usr/bin/env bash
# Runs scripts/update-contrast-cli.sh against a stubbed Artifactory: a curl on PATH that serves
# local files, with real archives built here.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0
PLATFORMS=(darwin-arm64 darwin-amd64 linux-arm64 linux-amd64)
current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$root/Formula/contrast-cli.rb")"
# The tests run on copies of the formula with known urls, so they don't depend on which archive
# names the formula currently uses: one naming the contrast-cli archives the script updates, and one
# naming the older contrast-cns archives it must refuse
formula="$tmp/contrast-cli.rb"
sed -e 's#/contrast-cns/#/contrast-cli/#' -e 's#/contrast-cns-#/contrast-cli-#' "$root/Formula/contrast-cli.rb" >"$formula"
old_urls="$tmp/contrast-cns-urls.rb"
sed -e 's#/contrast-cli/#/contrast-cns/#' -e 's#/contrast-cli-#/contrast-cns-#' "$formula" >"$old_urls"
NEW="$((${current%%.*} + 1)).0.0"

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# Serves <BASE_URL>/<path> from $SERVE/<path>, failing like curl -f when the file is absent
mkdir "$tmp/bin"
cat >"$tmp/bin/curl" <<'EOF'
#!/usr/bin/env bash
out="" url=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o) out="$2"; shift ;;
    https://*) url="$1" ;;
  esac
  shift
done
file="$SERVE/${url#https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cli/}"
[ -f "$file" ] || exit 22
if [ -n "$out" ]; then cp "$file" "$out"; else cat "$file"; fi
EOF
chmod +x "$tmp/bin/curl"

# <serve dir> <version> [<entry to leave out of each archive>] [<extra files under _internal/>]
make_release() {
  local serve="$1" version="$2" omit="${3:-}" extra="${4:-0}" platform stage
  mkdir -p "$serve/$version"
  for platform in "${PLATFORMS[@]}"; do
    stage="$(mktemp -d "$tmp/stage.XXXXXX")"
    mkdir -p "$stage/contrast-cli-$platform/_internal"
    echo "$platform" >"$stage/contrast-cli-$platform/contrast-cli"
    echo lib >"$stage/contrast-cli-$platform/_internal/lib"
    if [ "$extra" -gt 0 ]; then (cd "$stage/contrast-cli-$platform/_internal" && touch $(seq -f 'module-%05g.so' "$extra")); fi
    if [ -n "$omit" ]; then rm -r "${stage:?}/contrast-cli-$platform/$omit"; fi
    tar -czf "$serve/$version/contrast-cli-$platform.tar.gz" -C "$stage" "contrast-cli-$platform"
  done
}

# <name> <expected exit, or "nonzero"> <expected updated output, empty for none> <latest-version.txt content>
#   <override: "unset" or the value> [<entry to leave out of each archive>]
# Optional settings, given as environment assignments before the call:
#   SOURCE   formula to start from (default: the copy naming the contrast-cli archives)
#   CURRENT  version to put in the formula first (default: the real formula's)
#   TARGET   version to publish and expect (default $NEW)
#   EXTRA    number of extra files in each archive's _internal/
run_case() {
  local name="$1" expected="$2" updated="$3" latest="$4" override="$5" omit="${6:-}"
  local NEW="${TARGET:-$NEW}"
  local dir rc problems="" platform sum
  dir="$(mktemp -d "$tmp/case.XXXXXX")"
  mkdir -p "$dir/tap/scripts" "$dir/tap/Formula" "$dir/serve"
  cp "$root/scripts/update-contrast-cli.sh" "$dir/tap/scripts/"
  cp "${SOURCE:-$formula}" "$dir/tap/Formula/contrast-cli.rb"
  if [ -n "${CURRENT:-}" ]; then
    CURRENT="$CURRENT" perl -pi -e 's/^  version ".*"$/  version "$ENV{CURRENT}"/' "$dir/tap/Formula/contrast-cli.rb"
  fi
  cp "$dir/tap/Formula/contrast-cli.rb" "$dir/before.rb"
  printf '%s\n' "$latest" >"$dir/serve/latest-version.txt"
  make_release "$dir/serve" "$NEW" "$omit" "${EXTRA:-0}"
  : >"$dir/output"
  if [ "$override" = unset ]; then
    env -u CONTRAST_CLI_VERSION PATH="$tmp/bin:$PATH" SERVE="$dir/serve" GITHUB_OUTPUT="$dir/output" \
      "$dir/tap/scripts/update-contrast-cli.sh" >"$dir/log" 2>&1 && rc=0 || rc=$?
  else
    env CONTRAST_CLI_VERSION="$override" PATH="$tmp/bin:$PATH" SERVE="$dir/serve" GITHUB_OUTPUT="$dir/output" \
      "$dir/tap/scripts/update-contrast-cli.sh" >"$dir/log" 2>&1 && rc=0 || rc=$?
  fi

  if [ "$expected" = nonzero ]; then
    [ "$rc" != 0 ] || problems+=" exit 0, expected a failure;"
  elif [ "$rc" != "$expected" ]; then
    problems+=" exit $rc, expected $expected;"
  fi
  if [ -n "$updated" ] && ! grep -qx "updated=$updated" "$dir/output"; then
    problems+=" no updated=$updated output;"
  fi
  if [ "$updated" = true ]; then
    grep -qx "version=$NEW" "$dir/output" || problems+=" no version=$NEW output;"
    grep -qx "  version \"$NEW\"" "$dir/tap/Formula/contrast-cli.rb" || problems+=" formula version not $NEW;"
    for platform in "${PLATFORMS[@]}"; do
      sum="$(sha256 "$dir/serve/$NEW/contrast-cli-$platform.tar.gz")"
      ARCHIVE="contrast-cli-$platform.tar.gz" SUM="$sum" perl -0ne \
        'exit(/\Q$ENV{ARCHIVE}\E"\n      sha256 "\Q$ENV{SUM}\E"$/m ? 0 : 1)' "$dir/tap/Formula/contrast-cli.rb" \
        || problems+=" $platform sha is not $sum;"
    done
  elif [ "$expected" = 0 ] || [ -z "$omit" ]; then
    # Archive layout failures can leave a half-edited formula in the throwaway checkout; others must not touch it
    cmp -s "$dir/before.rb" "$dir/tap/Formula/contrast-cli.rb" || problems+=" formula changed;"
  fi

  if [ -z "$problems" ]; then
    echo "ok   $name"
  else
    echo "FAIL $name:$problems"
    cat "$dir/log"
    failures=$((failures + 1))
  fi
}

run_case "latest-version.txt newer" 0 true "VERSION=$NEW" unset
run_case "override newer, ignoring latest-version.txt" 0 true "VERSION=0.0.0" "$NEW"
run_case "override equal" 0 false "VERSION=$NEW" "$current"
run_case "override older" 0 false "VERSION=$NEW" 0.0.0
CURRENT=0.9.0 TARGET=0.10.0 run_case "0.9.0 to 0.10.0 sorts by number" 0 true "VERSION=0.10.0" unset
CURRENT=0.10.0 TARGET=0.9.0 run_case "0.10.0 to 0.9.0 is a downgrade" 0 false "VERSION=0.9.0" unset
# A listing longer than a pipe buffer, where grep -q exiting early would SIGPIPE a piped tar
EXTRA=2000 run_case "archive with a long listing" 0 true "VERSION=$NEW" unset
run_case "override set but empty" 1 "" "VERSION=$NEW" ""
run_case "override 1.2" 1 "" "VERSION=$NEW" 1.2
run_case "override v1.2.3" 1 "" "VERSION=$NEW" v1.2.3
run_case "override 1.2.3-rc1" 1 "" "VERSION=$NEW" 1.2.3-rc1
run_case "override with a leading zero" 1 "" "VERSION=$NEW" 09.9.9
run_case "empty latest-version.txt" 1 "" "" unset
run_case "archive without contrast-cli" 1 "" "VERSION=$NEW" unset contrast-cli
run_case "archive without _internal" 1 "" "VERSION=$NEW" unset _internal
SOURCE="$old_urls" run_case "formula urls naming the contrast-cns archives" nonzero "" "VERSION=$NEW" unset

[ "$failures" -eq 0 ]
