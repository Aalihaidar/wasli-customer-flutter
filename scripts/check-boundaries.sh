#!/usr/bin/env bash
# Checks the import rules between the folders under lib/, so the layers stay
# independent and every dependency points inward:
#
#   1. lib/core, lib/theme and lib/api never import lib/features, lib/app or
#      lib/main.dart.
#   2. The generated client in lib/api is imported only by a feature's data/
#      folder (and by lib/api itself), and lib/api imports nothing else of this
#      package.
#   3. A feature never imports lib/app, lib/main.dart, or another feature's
#      data/ or presentation/.
#   4. Inside a feature, only presentation/ (and the feature's barrel file)
#      imports presentation/.
#   5. A feature's domain/ is pure Dart: dart: libraries (not dart:ui) and
#      domain/ code only. No Flutter, no packages.
#   6. dart:io and dart:html are imported only in lib/core/platform and
#      lib/core/storage, where the per-platform implementations live.
#
# Import and export directives are both checked, conditional imports included.
#
# Usage: scripts/check-boundaries.sh   (exits 1 when a rule is broken)
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [[ ! -d lib || ! -f pubspec.yaml ]]; then
  echo "No Flutter project yet: import boundary check skipped."
  exit 0
fi

package="$(awk '/^name:/ { print $2; exit }' pubspec.yaml)"
status=0
files=0

# Prints the URIs of every import and export directive of a Dart file, one per
# line. A directive may span several lines (conditional imports).
directive_uris() {
  awk '
    /^[[:space:]]*(import|export)[[:space:]]/ { collecting = 1; text = "" }
    collecting {
      text = text " " $0
      if (index($0, ";") > 0) { print text; collecting = 0 }
    }
  ' "$1" | grep -oE "'[^']+'|\"[^\"]+\"" | tr -d "'\"" || true
}

# Turns a URI into a repository path (lib/...) when it points into this
# package; dart: and other packages' URIs are printed unchanged.
resolve() {
  local file="$1" uri="$2"
  case "$uri" in
    dart:*) echo "$uri" ;;
    "package:${package}/"*) echo "lib/${uri#"package:${package}/"}" ;;
    package:*) echo "$uri" ;;
    *) realpath -m --relative-to="$root" "$(dirname "$file")/$uri" ;;
  esac
}

fail() {
  echo "  $1 -> $2"
  echo "    $3"
  status=1
}

# Checks one directive: $1 the importing file, $2 the resolved target.
check() {
  local file="$1" target="$2" top feature layer target_feature=""
  IFS=/ read -r _ top feature layer _ <<< "$file"
  # A file directly in lib/features/<feature>/ (the barrel file) has no layer.
  if [[ "$top" != features || "$file" != "lib/features/${feature}/${layer}/"* ]]; then
    layer=""
  fi
  if [[ "$target" == lib/features/* ]]; then
    target_feature="${target#lib/features/}"
    target_feature="${target_feature%%/*}"
  fi

  # Rule 6
  if [[ "$target" == "dart:io" || "$target" == "dart:html" ]]; then
    case "$file" in
      lib/core/platform/* | lib/core/storage/*) ;;
      *) fail "$file" "$target" "dart:io and dart:html are imported only in lib/core/platform or lib/core/storage" ;;
    esac
  fi

  # Rule 2
  if [[ "$target" == lib/api/* ]]; then
    case "$file" in
      lib/api/* | lib/features/*/data/*) ;;
      *) fail "$file" "$target" "only a feature's data/ folder imports the generated client in lib/api" ;;
    esac
  fi
  if [[ "$top" == api && "$target" == lib/* && "$target" != lib/api/* ]]; then
    fail "$file" "$target" "lib/api is generated and imports nothing else of this package"
  fi

  case "$top" in
    core | theme | api)
      # Rule 1
      case "$target" in
        lib/features/* | lib/app/* | lib/main.dart)
          fail "$file" "$target" "lib/${top} never imports lib/features, lib/app or lib/main.dart" ;;
      esac
      ;;
    features)
      # Rule 3
      case "$target" in
        lib/app/* | lib/main.dart)
          fail "$file" "$target" "a feature never imports lib/app or lib/main.dart" ;;
        lib/features/*/data/* | lib/features/*/presentation/*)
          if [[ "$target_feature" != "$feature" ]]; then
            fail "$file" "$target" "a feature never imports another feature's data/ or presentation/"
          elif [[ "$target" == lib/features/*/presentation/* && -n "$layer" && "$layer" != presentation ]]; then
            # Rule 4
            fail "$file" "$target" "only presentation/ imports presentation/"
          fi
          ;;
      esac
      # Rule 5
      if [[ "$layer" == domain ]]; then
        case "$target" in
          dart:ui) fail "$file" "$target" "domain/ is pure Dart (no Flutter)" ;;
          dart:* | lib/features/*/domain/*) ;;
          *) fail "$file" "$target" "domain/ imports only dart: libraries and other domain/ code" ;;
        esac
      fi
      ;;
  esac
}

while IFS= read -r -d '' file; do
  files=$((files + 1))
  while IFS= read -r uri; do
    [[ -n "$uri" ]] || continue
    check "$file" "$(resolve "$file" "$uri")"
  done < <(directive_uris "$file")
done < <(find lib -type f -name '*.dart' -print0 | sort -z)

if [[ "$status" -ne 0 ]]; then
  echo "Import boundaries broken (rules at the top of scripts/check-boundaries.sh)."
  exit 1
fi
echo "Import boundaries OK (${files} files)."
