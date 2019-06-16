#!/bin/sh

# download additional fonts

fonts_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/fonts"
mkdir -p "${fonts_dir}"

for url in "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu Sans Mono Nerd Font Complete.ttf"; do
    if [ ! -e "${fonts_dir}/${url##*/}" ]; then
        echo "Downloading ${url##*/}..."
        (cd -- "${fonts_dir}" && wget -q -- "${url}")
    fi
done
