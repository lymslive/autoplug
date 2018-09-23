" File: plugin
" Author: lymslive
" Description: dynamic key map
" Create: 2018-06-06
" Modify: 2018-06-06

" CmdWin Map:
nnoremap <CR> q:k
nnoremap ? q/k
augroup DynmkeyEvent
    autocmd CmdwinEnter * call dynmkey#cmdwin#OnEnter()
    autocmd CmdwinLeave * call dynmkey#cmdwin#OnLeave()
augroup END

command -nargs=1 -bang Normal call dynmkey#normal#Unmap('<bang>', <q-args>)

" load: 
function! dynmkey#plugin#load() abort "{{{
    return 1
endfunction "}}}
