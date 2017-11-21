#!/bin/bash -e

printf "Which type of release would you like bump or minor or patch?"
read versionType

newVersion=`npm version --no-git-tag-version $versionType`
echo "Preparing new version ${newVersion}"

# echo "Type enter when you have updated the CHANGELOG.md for ${newVersion}"
# read proceed

echo "Running npm build"
npm run build

echo "Type enter to commit and tag"
read proceed
git add .
git commit -m "Updating to version ${newVersion}"
git tag -a ${newVersion} -m "Updating to version ${newVersion}"
git push --follow-tags

echo "Type enter publish to npm"
read proceed
npm publish

node build/del.js
