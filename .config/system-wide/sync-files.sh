#!/bin/bash

base_dir="${XDG_CONFIG_HOME:-"$HOME/.config"}/system-wide/"
ignore_file="${HOME}/.gitignore"
verbose=true


# OS detection
# The following variables will be set:
# OS - the name of the operating system
# FLAVOUR - the flavour of the operating system, e.g. GNU/Linux distibution
# FLAVOUR_LIKE - a space separated list of similar flavours, e.g. debian for kali
# VERSION - version of the OS flavour
# unknown values will be set to 'unknown'
if [[ "$(uname -o)" == "GNU/Linux" ]]; then
    OS='linux'
    if [[ -e /etc/os-release ]]; then
        FLAVOUR=$(grep '^ID=' /etc/os-release | cut -d= -f2)
        FLAVOUR_LIKE=$(grep '^ID_LIKE=' /etc/os-release | cut -d= -f2)
        VERSION=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2)
    fi
elif [[ "$(uname -o)" == 'Cygwin' ]]; then
    OS='cygwin'
    win_version="$(reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "ProductName" | grep -o "Windows .*")"
    case "${win_version}" in
        "Windows XP")
            FLAVOUR='xp' ;;
        "Windows Vista")
            FLAVOUR='vista' ;;
        "Windows 7"*)
            FLAVOUR='7' ;;
        "Windows 8.1"*)
            FLAVOUR='8.1' ;;
        "Windows 8"*)
            FLAVOUR='8' ;;
        "Windows 10"*)
            FLAVOUR='10' ;;
        "Windows Server 2003"*)
            FLAVOUR='2003' ;;
        "Windows Server 2008 R2"*)
            FLAVOUR='2008r2' ;;
        "Windows Server 2008"*)
            FLAVOUR='2008' ;;
        "Windows Server 2012 R2"*)
            FLAVOUR='2012r2' ;;
        "Windows Server 2012"*)
            FLAVOUR='2012' ;;
    esac
    unset win_version
    VERSION="$(reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "CSDVersion" | sed 's/Service Pack ([0-9])/sp\1/')"
fi
[[ -z "${OS}" ]] && OS="unknown"
[[ -z "${FLAVOUR}" ]] && FLAVOUR="unknown"
[[ -z "${FLAVOUR_LIKE}" ]] && FLAVOUR_LIKE="${FLAVOUR}"
[[ -z "${VERSION}" ]] && VERSION="unknown"


if ! command -v sudo &>/dev/null; then
    no_sudo_warning=true
    # sudo is not available, implement a stub
    function sudo() {
        args="$@"
        if command -v su &>/dev/null; then
            # emulate sudo behaviour using su (and hope the parameters do not contain options to sudo...)
            if ${no_sudo_warning}; then
                echo "Warning: Emulating sudo behaviour with 'su'. This is unreliable. Please install sudo."
                no_sudo_warning=false
            fi
            su -c "$args"
        else
            # su is not available either, this happens on cygwin
            # hope that we have sufficient privileges and run the parameters
            if ${no_sudo_warning}; then
                echo 'Warning: Sudo is unavailable. Running with normal privileges.'
                no_sudo_warning=false
            fi
            $args
        fi
    }
fi


# loop over all files, including all subdirectories
find "${base_dir}" -mindepth 2 -name "*.install" -prune -o -type f -print -o -type l -print | while read filename; do
    target_filename="/${filename#${base_dir}}"
    base_filename="$(basename "${filename}")"
    fuser='root' # target file owner
    fgroup='root' # target file group
    fperms='' # target file permissions (octal)

    # check $ignore_file
    if [[ -e "${ignore_file}" ]]; then
        while read pattern; do
            # skip the current file if the pattern matches
            [[ "${base_filename}" == ${pattern} ]] && continue 2
        done < "${ignore_file}"
    fi

    # source the .install file, if it is there
    [[ -e "${filename}.install" ]] && source "${filename}.install"

    target_dir="$(dirname -- "${target_filename}")"

    # find out if the local copy should go to the system or the other way round
    if [[ ! -e "${target_filename}" ]] && sudo [ ! -e "${target_filename}" ]; then
        # the target file does not exist
        to_system=true
    else
        # the target file does exist, check if it is accessible for normal users
        [[ -e "${target_filename}" ]] && sudo='' || sudo='sudo'
        # check which file is newer
        if ${sudo} [ "${filename}" -ot "${target_filename}" ]; then
            # target file is newer, copy it to the repository
            to_system=false
        elif ${sudo}  [ "${filename}" -nt "${target_filename}" ]; then
            # the file in the repository is newer, copy it to the target file
            to_system=true
        else
            # both files have the same age
            ${verbose} && echo "Skipping unchanged file ${target_filename}."
            continue
        fi
    fi

    if ${to_system}; then
        # check if sudo is needed
        if [[ -e "${target_filename}" ]]; then
            [[ -w "${target_filename}" ]] && sudo='' || sudo='sudo'
        elif [[ -e "${target_dir}" ]]; then
            [[ -w "${target_dir}" ]] && sudo='' || sudo='sudo'
        else
            sudo mkdir -p "${target_dir}"
            sudo='sudo'
        fi
        ${verbose} && echo "Installing ${target_filename} into the system."
        # keep permissions and times, but not ownership
        ${sudo} rsync --update --links --perms --times "${filename}" "${target_filename}"
        # make sure the file ownership is correct (root:root, unless overridden by .install)
        if [[ "$(${sudo} stat -c '%U:%G' -- "${target_filename}")" != "${fuser}:${fgroup}" ]]; then
            sudo chown "${fuser}:${fgroup}" -- "${target_filename}"
        fi
        # make sure that the permissions are correct (if $fperms is set)
        if [[ -n "${fperms}" && "$(${sudo} stat -c "%a" -- "${target_filename}")" != "${fperms}" ]]; then
            sudo chmod "${fperms}" -- "${target_filename}"
        fi
    else
        [[ -r "${target_filename}" ]] && sudo='' || sudo='sudo'
        ${verbose} && echo "Updating local copy of ${target_filename}."
        # keep permissions and times, but not ownership
        ${sudo} rsync --update --links --perms --times "${target_filename}" "${filename}"
        # make sure the copy is owned by the user, not root
        if [[ "$(stat -c "%U:%G" "${filename}")" != "${USER}:$(id --group --name)" ]]; then
            ${sudo} chown "${USER}:$(id --group --name)" -- "${filename}"
        fi
    fi

done
