#!/bin/bash
set -xeuo pipefail

# source the m environment
m ci env m > /dev/null
source m/.m/env.list
export $(cut -d= -f1 m/.m/env.list)

# build directory
target=.stage

# start with a clean build directory 
rm -rf "$target"
mkdir -p "$target"

# move files to the stage directory
cp -a ./src/. "$target"/
cp package.json "$target"/package.json

# Set the version
sed -i -e "s/0.0.0-PLACEHOLDER/$M_TAG/g" "./$target/package.json"

# create package
(
    cd "$target" && npm pack
)

# Only publish with the CI tool
[ "$M_CI" == "True" ] || exit 0

# Only publishing to github on every pr and master branch
npmTag=$(m ci npm_tag "$M_TAG")
npm publish "$target"/*.tgz --tag "$npmTag"

# Only on release
[ "$M_IS_RELEASE" == "True" ] || exit 0
m github release --owner "$M_OWNER" --repo "$M_REPO" --version "$M_TAG"
