#!/bin/bash

# Generate a complete versioned CBMC tap formula (cbmc@<version>) from
# Homebrew-core's own cbmc formula, re-hosting its bottles.
#
# The whole formula is derived from Homebrew-core's cbmc.rb verbatim, changing
# only two things:
#   * the class name (Cbmc -> CbmcAT<version>), and
#   * the `bottle do` block: a `root_url` pointing at this tap's release is
#     added and each bottle's sha256 is replaced with the re-hosted value.
# Everything else (url/tag/revision, dependencies, install/test blocks, ...) is
# copied as-is, so the tap formula can never drift from the upstream build
# recipe.
#
# Bottles are downloaded straight from the GitHub Packages (ghcr.io) OCI
# registry by digest, rather than via `brew fetch --bottle-tag=<tag>` (which
# only returns bottles for the runner's *native* platform). That works from any
# single runner (e.g. Linux) for every platform Homebrew-core ships. Each
# bottle is repackaged so it unpacks under `cbmc@<version>/<version>` (as a
# versioned formula requires) with its embedded class renamed, which changes
# the archive, so a fresh sha256 is computed per tag.
#
# The generated formula is written to stdout; the re-hosted bottle tarballs are
# left in the working directory for uploading.
#
# Environment overrides (used by tests):
#   CORE_RB   path to Homebrew-core's cbmc.rb (default: located via brew/GitHub)

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

# Emit the whole formula, transforming only the class name and bottle block.
in_bottle=0
while IFS= read -r line
do
  if [[ ${in_bottle} -eq 0 && "${line}" == "  bottle do" ]]
  then
    in_bottle=1
    echo "  bottle do"
    echo "    root_url \"${ROOT_URL}\""
    continue
  fi
  if [[ ${in_bottle} -eq 1 ]]
  then
    case "${line}" in
      "  end")
        in_bottle=0
        echo "  end"
        ;;
      *root_url*)
        # Drop any upstream root_url; ours was emitted above.
        ;;
      *sha256*)
        emit_line "${line}"
        ;;
      *)
        # Anything else inside the block (e.g. `rebuild`) is kept verbatim.
        echo "${line}"
        ;;
    esac
    continue
  fi
  if [[ "${line}" == "class Cbmc < Formula" ]]
  then
    echo "class ${FORMULA_VERSION} < Formula"
  else
    echo "${line}"
  fi
done <"${CORE_RB}"
