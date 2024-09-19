#!/bin/bash

VERSION=$1

if [[ -z "${VERSION}" ]]; then
  echo >&2 "Fatal error: VERSION not set"
  echo >&2 "Fatal error: Need to provide version, example: 5.62.0"
  exit 2
fi

CBMC_STRING="CbmcAT"
VERSION_PROCESSED="${VERSION//./}"
FORMULA_VERSION="${CBMC_STRING}${VERSION_PROCESSED}"

echo "bottle do"
echo "  root_url \"https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies\""
for TAG in "arm64_sonoma" "arm64_ventura" "arm64_monterey" "sonoma" "ventura" "monterey" "x86_64_linux"
do
    #echo "Processing bottle for $VERSION -- $TAG"
    OUTPUT=$(brew fetch cbmc --bottle-tag="${TAG}")
    OUTPUT=$(echo "${OUTPUT}" | tail -n -2)

    pat1='Downloaded to: (.*\.{1})(tgz|tar\.gz)'
    pat2='Already downloaded: (.*\.{1})(tgz|tar\.gz)'

    if [[ ${OUTPUT} =~ ${pat1} ]]; then
        BOTTLE_NAME=${BASH_REMATCH[1]}
    elif [[ ${OUTPUT} =~ ${pat2} ]]; then
        BOTTLE_NAME=${BASH_REMATCH[1]}
    else
        continue
    fi

    BOTTLE_NAME+="tar.gz"

    tar -xzf "${BOTTLE_NAME}"
    mv cbmc cbmc@"${VERSION}"
    sed -iu "s/class Cbmc/class ${FORMULA_VERSION}/g" "cbmc@${VERSION}/${VERSION}/.brew/cbmc.rb"
    tar czf "cbmc@${VERSION}-${VERSION}.${TAG}.bottle.tar.gz" cbmc@"${VERSION}"
    rm -rf cbmc@"${VERSION}"
    SHA=$(shasum -a 256 "cbmc@${VERSION}-${VERSION}.${TAG}.bottle.tar.gz")
    TAG_SPACED=$(printf "%-60s" "  sha256 cellar: :any_skip_relocation, ${TAG}:")
    LINE="${TAG_SPACED}\"${SHA%%[[:space:]]*}\""
    echo "${LINE}"
done
echo end
