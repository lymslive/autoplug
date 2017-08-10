" Class: vtmder#plugin
" Author: lymslive
" Description: like Total Commander and midnight commander but in vim
" Create: 2017-08-10
" Modify: 2017-08-10

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" LOAD:
let s:load = 1
function! vtmder#plugin#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}
echo 'vtmder#plugin#load ...'

