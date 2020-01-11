" File: jumps
" Author: lymslive
" Description: action config for :jumps command
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#command#jumps#space = s:
let s:description = 'list all jumps, CR to jump there'

" Func: #CR 
function! vnite#command#jumps#CR(message) abort
    let l:text = a:message.text
    let l:tokens = matchlist(l:text, '^\s*\d\+\s\+\(\d\+\)\s\+\(\d\+\)\s\+\(.\+\)$')
    if empty(l:tokens)
        echoerr 'no jump in this message line'
        return ''
    endif
    let [l:line, l:col, l:file] = l:tokens
    return printf('EditFLC ', l:file, l:line, l:col)
endfunction

function! vnite#command#jumps#private() abort
    return s:
endfunction
