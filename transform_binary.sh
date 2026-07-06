#!/bin/bash

# Generate the `bottle do` block for a versioned CBMC tap formula
# (cbmc@<version>) by re-hosting Homebrew-core's own bottles.
#
# Rather than `brew fetch --bottle-tag=<tag>` (which only returns bottles for
# the runner's *native* platform and silently skips all others), we take the
# authoritative list of tags directly from Homebrew-core's cbmc formula and
# download each bottle blob straight from the GitHub Packages (ghcr.io) OCI
# registry. That works from any single runner (e.g. Linux) for every platform,
# so the generated formula covers all architectures Homebrew-core ships.
#
# The bottle tar is repackaged so it unpacks under `cbmc@<version>/<version>`
# (as a versioned formula requires) and its embedded formula class is renamed;
# this changes the archive, so a fresh sha256 is computed per tag.
#
# Environment overrides (used by tests):
#   CORE_RB   path to Homebrew-core's cbmc.rb (default: `brew formula cbmc`)

set -euo pipefail

VERSION=$1

if [[ -z "${VERSION}" ]]
then
  echo >&2 "Fatal error: VERSION not set"
  echo >&2 "Fatal error: Need to provide version, example: 5.62.0"
  exit 2
fi

FORMULA_VERSION="CbmcAT${VERSION//./}"
ROOT_URL="https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
GHCR_REPO="homebrew/core/cbmc"

# Locate Homebrew-core's cbmc formula. `brew formula` only yields a path when
# the core tap is checked out locally; under Homebrew's default API mode (as on
# CI) it prints nothing, so fall back to fetching the formula from GitHub.
if [[ -z "${CORE_RB:-}" ]]
then
  CORE_RB="$(brew formula cbmc 2>/dev/null || true)"
fi
if [[ -z "${CORE_RB}" || ! -f "${CORE_RB}" ]]
then
  CORE_RB="$(mktemp)"
  curl -fsSL "https://raw.githubusercontent.com/Homebrew/homebrew-core/master/Formula/c/cbmc.rb" -o "${CORE_RB}"
fi
if ! grep -q "tag:[[:space:]]*\"cbmc-${VERSION}\"" "${CORE_RB}"
then
  echo >&2 "Fatal error: Homebrew-core cbmc formula is not at version ${VERSION} (CORE_RB=${CORE_RB})"
  exit 1
fi

# Obtain an anonymous pull token for the public Homebrew-core bottle registry.
ghcr_token() {
  curl -fsSL "https://ghcr.io/token?service=ghcr.io&scope=repository:${GHCR_REPO}:pull" |
    sed -E 's/.*"token":"([^"]+)".*/\1/'
}

# Extract the bottle block from Homebrew-core's formula, keeping its canonical
# ordering, per-tag `cellar:` values and formatting - we only substitute the
# root_url and the (repackaged) sha256 values, so `brew style` stays happy.
block=$(sed -n '/^  bottle do$/,/^  end$/p' "${CORE_RB}")
if [[ -z "${block}" ]]
then
  echo >&2 "Fatal error: no bottle block found in ${CORE_RB}"
  exit 1
fi

token=""

emit_line() {
  # $1: the original sha256 line from Homebrew-core (gives us cellar + tag)
  local line="$1"
  # Parse the tag and its digest from a Homebrew-core bottle line such as
  #   sha256 cellar: :any_skip_relocation, arm64_sonoma: "<hex digest>"
  # (the `cellar:` clause is optional). The whole expected structure must
  # match, so any deviation (reformatting, a trailing comment, ...) fails fast
  # rather than silently yielding a bogus tag/digest.
  local tag digest
  local re='^[[:space:]]*sha256[[:space:]]+(cellar:[[:space:]]*[^,]+,[[:space:]]*)?([A-Za-z0-9_]+):[[:space:]]*"([0-9a-f]{64})"[[:space:]]*$'
  if [[ ! "${line}" =~ ${re} ]]
  then
    echo >&2 "Fatal error: could not parse bottle line: ${line}"
    exit 1
  fi
  tag="${BASH_REMATCH[2]}"
  digest="${BASH_REMATCH[3]}"

  # Download the Homebrew-core bottle blob for this tag directly from ghcr.
  # A fresh token is fetched per download as registry tokens are short-lived.
  token=$(ghcr_token)
  curl -fsSL \
    -H "Authorization: Bearer ${token}" \
    -H "Accept: application/vnd.oci.image.layer.v1.tar+gzip" \
    "https://ghcr.io/v2/${GHCR_REPO}/blobs/sha256:${digest}" \
    -o core-bottle.tar.gz

  # Repackage cbmc/<version> -> cbmc@<version>/<version> and rename the class.
  rm -rf cbmc "cbmc@${VERSION}"
  tar -xzf core-bottle.tar.gz
  mv cbmc "cbmc@${VERSION}"
  sed -i.bak "s/class Cbmc/class ${FORMULA_VERSION}/g" \
    "cbmc@${VERSION}/${VERSION}/.brew/cbmc.rb"
  rm -f "cbmc@${VERSION}/${VERSION}/.brew/cbmc.rb.bak"

  local outfile="cbmc@${VERSION}-${VERSION}.${tag}.bottle.tar.gz"
  tar czf "${outfile}" "cbmc@${VERSION}"
  rm -rf "cbmc@${VERSION}" core-bottle.tar.gz

  local sha
  sha=$(shasum -a 256 "${outfile}" | cut -d' ' -f1)

  # Re-emit the original line with the repackaged sha256 substituted in, so the
  # cellar value, tag ordering and alignment are inherited verbatim.
  echo "${line}" | sed -E "s/\"[0-9a-f]+\"$/\"${sha}\"/"
}

while IFS= read -r line
do
  case "${line}" in
    *"bottle do"*)
      echo "  bottle do"
      echo "    root_url \"${ROOT_URL}\""
      ;;
    *"root_url"*)
      # Drop Homebrew-core's root_url; ours was emitted above.
      ;;
    *sha256*)
      emit_line "${line}"
      ;;
    *"end"*)
      echo "  end"
      ;;
    *)
      echo "${line}"
      ;;
  esac
done <<<"${block}"
