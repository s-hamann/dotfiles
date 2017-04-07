" Automatically enable spell checking for markdown files.
setlocal spell
" Enable folding for markdown files.
let g:markdown_folding = 1

" vim-markdown plugin {{{
let g:vim_markdown_toc_autofit = 1
if exists(':Toc')
    nnoremap <buffer> <F9> :Toc<CR>
endif
" }}}
