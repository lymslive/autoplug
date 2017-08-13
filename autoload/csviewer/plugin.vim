" Class: csviewer#plugin
" Author: lymslive
" Description: csv editor and viewer
" Create: 2017-08-10
" Modify: 2017-08-13

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

augroup CSVIEWER
    autocmd!
    autocmd BufRead,BufNewFile *.csv,*.CSV call csviewer#command#BufSource()
augroup END

" LOAD:
let s:load = 1
function! csviewer#plugin#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}
echo 'csviewer#plugin#load ...'
