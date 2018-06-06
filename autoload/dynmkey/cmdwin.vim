" File: cmdwin
" Author: lymslive
" Description: 
" Create: 2018-06-06
" Modify: 2018-06-06

" OnEnter: 
function! dynmkey#cmdwin#OnEnter() abort "{{{
    let b:cpt_save = &complete 
    setlocal complete=.

    nnoremap <buffer> <CR> <CR>
    nnoremap <buffer> q :q<CR>
    inoremap <buffer> <C-N> <Down>
    inoremap <buffer> <C-P> <Up>
endfunction "}}}

" OnLeave: 
function! dynmkey#cmdwin#OnLeave() abort "{{{
    let &complete = b:cpt_save
endfunction "}}}

