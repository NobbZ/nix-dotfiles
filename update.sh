#!/usr/bin/env bash

set -ex

branch=$(git rev-parse --abbrev-ref HEAD)
workbranch=update-repositories
git checkout -b "${workbranch}"

function has_changed () {
    result=1
    git status --porcelain | while read -r line; do
        if [ "M nix/sources.json" == "${line}" ]; then result=0; fi
    done
    return ${result}
}

for repo in $(jq --raw-output 'keys[]' < nix/sources.json); do
    printf "Updating %s\n" "${repo}"
    niv update ${repo}
    if $(has_changed); then
        git add nix/sources.json
        git commit -m "bump ${repo}"
    fi
done

git checkout "${branch}"
git merge "${workbranch}"
git branch -d "${workbranch}"
