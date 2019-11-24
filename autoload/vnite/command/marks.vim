" File: marks
" Author: lymslive
" Description: action config for :marks command
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#command#marks#space = s:
let s:description = 'list all marks, CR to jump there'

" Func: #CR 
function! vnite#command#marks#CR(message) abort
    let l:text = a:message.text
    let l:mark = matchstr(l:text, '^ \zs.\ze')
    if empty(l:mark)
        echoerr 'no mark in this message line'
        return ''
    endif
    return printf('normal! `%s', l:mark)
endfunction
