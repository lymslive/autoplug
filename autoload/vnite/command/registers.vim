" File: registers
" Author: lymslive
" Description: action config for :registers command
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#command#registers#space = s:
let s:description = 'list all registers, CR to paste under cursor'

" Func: #CR 
function! vnite#command#registers#CR(message) abort
    let l:text = a:message.text
    let l:register = matchstr(l:text, '^"\zs.\ze')
    if empty(l:register)
        echoerr 'it seems not output from :registers'
        return ''
    endif
    return printf('normal! "%sp', l:register)
endfunction
