setlocal nonumber
setlocal foldcolumn=0
setlocal nofoldenable
setlocal spell " Enable spell checking for commit messages by default.

" Start on the first line in insert mode.
au BufEnter * call setpos('.', [0,1,1,0])
startinsert
