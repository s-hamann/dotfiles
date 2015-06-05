#!/bin/bash

base_dir="${XDG_CONFIG_HOME:-"$HOME/.config"}/system-wide/"
ignore_file="${HOME}/.gitignore"
verbose=true

OS='unknown'
FLAVOUR='unknown'
# OS detection
if [[ "$(uname -o)" == "GNU/Linux" ]]; then
	OS='linux'
	if [[ -e /etc/gentoo-release ]]; then
		FLAVOUR='gentoo'
	elif [[ -e /etc/debian_version ]]; then
		FLAVOUR='debian'
	elif [[ -e /etc/arch-release ]]; then
		FLAVOUR='arch'
	elif [[ -e /etc/SuSE-release ]]; then
		FLAVOUR='suse'
	elif [[ -c /etc/redhat-release ]]; then
		if grep --quiet -F 'CentOS' /etc/redhat-release; then
			FLAVOUR='centos'
		else
			FLAVOUR='redhat'
		fi
	elif [[ -e /etc/fedora-release ]]; then
		FLAVOUR='fedora'
	elif [[ -e /etc/slackware-release ]]; then
		FLAVOUR='slackware'
	elif [[ -e /etc/lsb-release ]]; then
		if grep --quiet -F 'Ubuntu' /etc/lsb-release; then
			FLAVOUR='ubuntu'
		fi
	fi
elif [[ "$(uname -o)" == 'Cygwin' ]]; then
	OS='cygwin'
	win_version="$(reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "ProductName" | grep -o "Microsoft Windows .*")"
	case "${win_version}" in
		"Microsoft Windows XP")
			FLAVOUR='xp' ;;
		"Microsoft Windows Vista")
			FLAVOUR='vista' ;;
		"Microsoft Windows 7")
			FLAVOUR='7' ;;
	esac
	unset win_version
fi

# loop over all files, including all subdirectories
find "${base_dir}" -mindepth 2 -name "*.install" -prune -o -type f -print -o -type l -print | while read filename; do
	target_filename="/${filename#${base_dir}}"
	base_filename="$(basename "${filename}")"
	fuser='root' # target file owner
	fgroup='root' # target file group
	fperms='' # target file permissions (octal)

	# check $ignore_file
	while read pattern; do
		# skip the current file if the pattern matches
		[[ "${base_filename}" == ${pattern} ]] && continue 2
	done < "${ignore_file}"

	# source the .install file, if it is there
	[[ -e "${filename}.install" ]] && source "${filename}.install"

	target_dir="$(dirname -- "${target_filename}")"

	# find out if the local copy should go to the system or the other way round
	if [[ ! -e "${target_filename}" ]] && sudo [ ! -e "${target_filename}" ]; then
		# the target file does not exist
		to_system=true
	else
		# the target file does exist, check if it is accessible for normal users
		[[ -e "${target_file}" ]] && sudo='' || sudo='sudo'
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
