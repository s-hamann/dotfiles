#!/bin/sh

[ -e ~/.vim/bundle/Vundle.vim ] && exit 0

# install Vundle
mkdir -p ~/.vim/bundle/
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Installing plugins from this hook causes too many issues...
echo '* Please run the following command to install the plugins:'
echo '  vim -c PluginInstall'
