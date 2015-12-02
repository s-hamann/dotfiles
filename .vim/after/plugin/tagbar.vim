if exists(':Tagbar')
    " Make F9 open/close the tagbar window
    noremap <silent> <F9> :TagbarToggle<CR>
    " Default tagbar width
    let g:tagbar_width = 25
    " When zooming, make the window as wide as the longest visible tag
    let g:tagbar_zoomwidth = 0
    " Do not sort tags by default
    let g:tagbar_sort = 0
    " Add rudimentary support for Markdown
    let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:Heading_L1',
        \ 'i:Heading_L2',
        \ 'k:Heading_L3'
    \ ]
\ }
endif
