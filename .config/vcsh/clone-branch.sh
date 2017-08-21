#!/bin/bash

if [[ $# -gt 1 || "$1" == '-h' || "$1" == '--help' ]]; then
    echo "Usage: $0 [<branch>]"
    echo "  Without <branch> list the known remote branches."
    echo "  When <branch> is given, clone it as a new vcsh repository."
    exit 1
fi

if [[ $# -eq 0 ]]; then

    vcsh base for-each-ref refs/remotes --format='%(refname)' | while read -r line; do
        echo "${line#refs/remotes/*/}"
    done

else

    branch="$1"

    # check if $branch is already tracked
    if vcsh list | grep -F -q -x "${branch}"; then
        echo "fatal: vcsh already tracks '${branch}'" >&2
        exit 2
    fi

    # get the remote URL for the repository
    url="$(vcsh base config --get remote.origin.url)"
    if [[ -z "${url}" ]]; then
        echo "fatal: no remote url found" >&2
        exit 3
    fi

    # clone it
    vcsh clone "${url}" "${branch}" -b "${branch}"

    # make git ignore other branches when fetching
    vcsh "${branch}" config --local remote.origin.fetch "+refs/heads/${branch}:refs/remotes/origin/${branch}"

fi
