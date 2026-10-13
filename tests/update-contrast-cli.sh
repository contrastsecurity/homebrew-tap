#!/usr/bin/env bash
# Runs scripts/update-contrast-cli.sh against a stubbed Artifactory: a curl on PATH that serves
# local files, with real archives built here.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0
PLATFORMS=(darwin-arm64 darwin-amd64 linux-arm64 linux-amd64)
NEW=9.9.9
current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$root/Formula/contrast-cli.rb")"

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
file="$SERVE/${url#https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cns/}"
[ -f "$file" ] || exit 22
if [ -n "$out" ]; then cp "$file" "$out"; else cat "$file"; fi
EOF
chmod +x "$tmp/bin/curl"

# <serve dir> <version> [<entry to leave out of each archive>]
make_release() {
  local serve="$1" version="$2" omit="${3:-}" platform stage
  mkdir -p "$serve/$version"
  for platform in "${PLATFORMS[@]}"; do
    stage="$(mktemp -d "$tmp/stage.XXXXXX")"
    mkdir -p "$stage/contrast-cns-$platform/_internal"
    echo "$platform" >"$stage/contrast-cns-$platform/contrast-cli"
    echo lib >"$stage/contrast-cns-$platform/_internal/lib"
    if [ -n "$omit" ]; then rm -r "${stage:?}/contrast-cns-$platform/$omit"; fi
    tar -czf "$serve/$version/contrast-cns-$platform.tar.gz" -C "$stage" "contrast-cns-$platform"
  done
}

# <name> <expected exit> <expected updated output, empty for none> <latest-version.txt content>
#   <override: "unset" or the value> [<entry to leave out of each archive>]
run_case() {
  local name="$1" expected="$2" updated="$3" latest="$4" override="$5" omit="${6:-}"
  local dir rc problems="" platform sum
  dir="$(mktemp -d "$tmp/case.XXXXXX")"
  mkdir -p "$dir/tap/scripts" "$dir/tap/Formula" "$dir/serve"
  cp "$root/scripts/update-contrast-cli.sh" "$dir/tap/scripts/"
  cp "$root/Formula/contrast-cli.rb" "$dir/tap/Formula/"
  printf '%s\n' "$latest" >"$dir/serve/latest-version.txt"
  make_release "$dir/serve" "$NEW" "$omit"
  : >"$dir/output"
  if [ "$override" = unset ]; then
    env -u CONTRAST_CLI_VERSION PATH="$tmp/bin:$PATH" SERVE="$dir/serve" GITHUB_OUTPUT="$dir/output" \
      "$dir/tap/scripts/update-contrast-cli.sh" >"$dir/log" 2>&1 && rc=0 || rc=$?
  else
    env CONTRAST_CLI_VERSION="$override" PATH="$tmp/bin:$PATH" SERVE="$dir/serve" GITHUB_OUTPUT="$dir/output" \
      "$dir/tap/scripts/update-contrast-cli.sh" >"$dir/log" 2>&1 && rc=0 || rc=$?
  fi

  [ "$rc" = "$expected" ] || problems+=" exit $rc, expected $expected;"
  if [ -n "$updated" ] && ! grep -qx "updated=$updated" "$dir/output"; then
    problems+=" no updated=$updated output;"
  fi
  if [ "$updated" = true ]; then
    grep -qx "version=$NEW" "$dir/output" || problems+=" no version=$NEW output;"
    grep -qx "  version \"$NEW\"" "$dir/tap/Formula/contrast-cli.rb" || problems+=" formula version not $NEW;"
    for platform in "${PLATFORMS[@]}"; do
      sum="$(sha256 "$dir/serve/$NEW/contrast-cns-$platform.tar.gz")"
      ARCHIVE="contrast-cns-$platform.tar.gz" SUM="$sum" perl -0ne \
        'exit(/\Q$ENV{ARCHIVE}\E"\n      sha256 "\Q$ENV{SUM}\E"$/m ? 0 : 1)' "$dir/tap/Formula/contrast-cli.rb" \
        || problems+=" $platform sha is not $sum;"
    done
  elif [ "$expected" = 0 ] || [ -z "$omit" ]; then
    # Archive layout failures can leave a half-edited formula in the throwaway checkout; others must not touch it
    cmp -s "$root/Formula/contrast-cli.rb" "$dir/tap/Formula/contrast-cli.rb" || problems+=" formula changed;"
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
run_case "override set but empty" 1 "" "VERSION=$NEW" ""
run_case "override 1.2" 1 "" "VERSION=$NEW" 1.2
run_case "override v1.2.3" 1 "" "VERSION=$NEW" v1.2.3
run_case "override 1.2.3-rc1" 1 "" "VERSION=$NEW" 1.2.3-rc1
run_case "override with a leading zero" 1 "" "VERSION=$NEW" 09.9.9
run_case "empty latest-version.txt" 1 "" "" unset
run_case "archive without contrast-cli" 1 "" "VERSION=$NEW" unset contrast-cli
run_case "archive without _internal" 1 "" "VERSION=$NEW" unset _internal

[ "$failures" -eq 0 ]
