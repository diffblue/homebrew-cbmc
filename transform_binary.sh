#!/bin/bash

VERSION=$1

if [[ -z "${VERSION}" ]]
then
  echo >&2 "Fatal error: VERSION not set"
  echo >&2 "Fatal error: Need to provide version, example: 5.62.0"
  exit 2
fi

CBMC_STRING="CbmcAT"
VERSION_PROCESSED="${VERSION//./}"
FORMULA_VERSION="${CBMC_STRING}${VERSION_PROCESSED}"
TAGS=(
  "arm64_sonoma"
  "arm64_ventura"
  "arm64_monterey"
  "arm64_tahoe"
  "arm64_sequoia"
  "sonoma"
  "ventura"
  "monterey"
  "arm64_linux"
  "x86_64_linux"
)

echo "  bottle do"
echo "    root_url \"https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies\""
for TAG in "${TAGS[@]}"
do
  #echo "Processing bottle for $VERSION -- $TAG"
  brew fetch cbmc --bottle-tag="${TAG}" >/dev/null
  BOTTLE_NAME=$(brew --cache cbmc --bottle-tag="${TAG}")

  if [[ -z "${BOTTLE_NAME}" ]]
  then
    continue
  fi

  tar -xzf "${BOTTLE_NAME}"
  mv cbmc cbmc@"${VERSION}"
  sed -iu "s/class Cbmc/class ${FORMULA_VERSION}/g" "cbmc@${VERSION}/${VERSION}/.brew/cbmc.rb"
  tar czf "cbmc@${VERSION}-${VERSION}.${TAG}.bottle.tar.gz" cbmc@"${VERSION}"
  rm -rf cbmc@"${VERSION}"
  SHA=$(shasum -a 256 "cbmc@${VERSION}-${VERSION}.${TAG}.bottle.tar.gz")
  TAG_SPACED=$(printf "%-60s" "    sha256 cellar: :any_skip_relocation, ${TAG}:")
  LINE="${TAG_SPACED}\"${SHA%%[[:space:]]*}\""
  echo "${LINE}"
done
echo "  end"
