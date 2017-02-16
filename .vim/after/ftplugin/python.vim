" vim: foldmethod=marker

" Make K look up things in python's documentation.
setlocal keywordprg=pydoc
" Fold based on indention.
setlocal foldmethod=indent

" Enable all optional highlighting.
let python_highlight_all = 1

" PEP 8 python coding guidelines. {{{
setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab
setlocal textwidth=79
setlocal colorcolumn=80
" }}}

" Do not visually wrap long lines.
setlocal nowrap

" Automatically set the width of the current window. {{{
if has('autocmd')
    augroup AutoSizeWindow
        " This makes the current window at least 79 characters wide (not
        " counting the fold, sign and number columns).
        " The sign column is always 2 characters wide if present. It is used
        " by gitgutter, Flake8 and others and is expected to be there most of
        " the time.
        " The width of the number column is tricky. If number is set, the
        " width is numberwidth or the greatest length of the line number of
        " all lines, whichever is greater. As the last line has the highest
        " an therefore longest line number, it is used instead of the maximum
        " over all line numbers.
        " However, there is also a space between the number column and the
        " buffer contents, which is already taken into account by numberwidth,
        " but not by the strlen of the line numbers.
        autocmd! WinEnter <buffer> 
                \ let s:leftcols = &foldenable * &foldcolumn + 2 + (or(&number, &relativenumber) * (max([&numberwidth, (&number * strlen(line('$'))) + 1]))) |
                \ if winwidth(0) < &columns && winwidth(0) < 79 + s:leftcols && &columns >= 79 + s:leftcols |
                \     exec 'vertical resize ' . (79 + s:leftcols) |
                \ endif
    augroup END
else
    " This is the simple alternative.
    " Note: The autocommand solution above is at least 20% cooler, since it
    " takes the additional columns on the left into account.
    setlocal winwidth=81
endif
" }}}

" vim-flake8 plugin {{{
" Use my custom flake8 wrapper that detects the correct python version.
if filereadable(glob("~/bin/flake8"))
    let g:flake8_cmd=glob("~/bin/flake8")
endif
" Automatically run Flake8 when saving files.
if has('autocmd') && exists('*Flake8')
    augroup AutoFlake
        autocmd! BufWritePre <buffer> let b:modified=&modified
        autocmd! BufWritePost <buffer> if b:modified | silent call Flake8() | endif
    augroup END
endif
" Show errors and warnings in the gutter.
let g:flake8_show_in_gutter=1
" }}}

" jedi-vim plugin {{{
" Do not map anything to autocomplete.
let g:jedi#completions_command = ''
" }}}
