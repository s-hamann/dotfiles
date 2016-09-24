#!/bin/bash

# Do not try to match a literal * if there are no undo files
shopt -s nullglob

if [[ "$1" == '-h' || "$1" == '--help' ]]; then
    echo "Usage: $(basename -- "$0") [<path>, [<path>, ...]]"
    echo "  where <path> is a directory containing vim's undo files,"
    echo "  i.e. the setting of undodir in vim."
    echo "  If <path> is not given, it is automatically obtained from vim."
    echo "  This script deletes all files in <path> that do not appear to be an undo file"
    echo "  for an existing file."
    exit 0
elif [[ -z "$1" ]]; then
    # Get undodirs from vim, remove any non-printable characters, split at ,
    IFS=',' read -r -a undodirs <<< "$(vim -c "execute 'silent !echo ' . &undodir | quit" 2>/dev/null | egrep -o '\.?/[[:print:]]*')"
    # Remove leading spaces (vim ignores them)
    undodirs=( "${undodirs[@]# }" )
    # Remove relative paths (starting with ./)
    undodirs=( "${undodirs[@]##.\/*}" )
else
    undodirs=( "$@" )
fi

for undodir in "${undodirs[@]}"; do
    if [[ ! -d "${undodir}" ]]; then
        echo "${undodir}: No such directory." >&2
        continue
    fi

    cd -- "${undodir}" || continue

    # Iterate over all non-hidden files
    for undofile in *; do
        if [[ "${undofile}" == "${undofile#%}" ]]; then
            # The file name does not start with %
            echo "File '${undofile}' does not seem to be a vim undo file. Skipping." >&2
            continue
        fi
        # Try to recover the original path (fails if it contains a %)
        originalfile="${undofile//%//}"
        if [[ ! -e "${originalfile}" ]]; then
            # Undofile seems orphaned, remove it
            rm -f -- "${undofile}"
        fi
    done
done
