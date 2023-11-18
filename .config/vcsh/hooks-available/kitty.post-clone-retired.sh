#!/bin/sh

# download additional fonts

command -v wget 2>/dev/null >/dev/null || exit
command -v unzip 2>/dev/null >/dev/null || exit

fonts_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/fonts"
mkdir -p "${fonts_dir}"

tmpdir="$(mktemp -d -p "${TMPDIR:-/tmp}" font.XXXXXX)"
trap "rm -rf -- '${tmpdir}'" EXIT QUIT INT HUP

url='https://github.com/ryanoasis/nerd-fonts/releases/latest/download/DejaVuSansMono.zip'
echo "Downloading ${url##*/}..."
wget "${url}" -O "${tmpdir}/nerdfont.zip"
(cd -- "${fonts_dir}" && unzip "${tmpdir}/nerdfont.zip" "*.ttf")
