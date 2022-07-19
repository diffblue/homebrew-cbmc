#!/bin/bash

VERSION=$1

for TAG in "arm64_monterey" "arm64_big_sur" "monterey" "big_sur" "catalina" "x86_64_linux"
do
    echo "Processing bottle for $VERSION -- $TAG"
    OUTPUT=$(brew fetch cbmc --bottle-tag=$TAG)
    OUTPUT=$(echo "$OUTPUT" | tail -n -2)

    pat1='Downloaded to: (.*\.{1})(tgz|tar\.gz)'
    pat2='Already downloaded: (.*\.{1})(tgz|tar\.gz)'

    if [[ $OUTPUT =~ $pat1 ]]; then
        BOTTLE_NAME=${BASH_REMATCH[1]}
        BOTTLE_NAME+="tar.gz"

        tar -xzf $BOTTLE_NAME
        mv cbmc cbmc-$1
        sed -iu 's/class Cbmc/class CbmcAT5610/g' cbmc-$1/$1/.brew/cbmc.rb
        tar czf cbmc-$1-$TAG.bottle.tar.gz cbmc-$1
        rm -rf cbmc-$1
        SHA=$(shasum -a 256 cbmc-$1-$TAG.bottle.tar.gz)
        echo "$SHA"
    elif [[ $OUTPUT =~ $pat2 ]]; then
        BOTTLE_NAME=${BASH_REMATCH[1]}
        BOTTLE_NAME+="tar.gz"

        tar -xzf $BOTTLE_NAME
        mv cbmc cbmc-$1
        sed -iu 's/class Cbmc/class CbmcAT5610/g' cbmc-$1/$1/.brew/cbmc.rb
        tar czf cbmc-$1-$TAG.bottle.tar.gz cbmc-$1
        rm -rf cbmc-$1
        SHA=$(shasum -a 256 cbmc-$1-$TAG.bottle.tar.gz)
        echo "$SHA"
    fi
done
