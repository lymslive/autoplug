" Class: csviewer#plugin
" Author: lymslive
" Description: csv editor and viewer
" Create: 2017-08-10
" Modify: 2017-08-10

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" LOAD:
let s:load = 1
function! csviewer#plugin#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}
echo 'csviewer#plugin#load ...'
