" File: clist
" Author: lymslive
" Description: vnite command for clist
" Create: 2019-11-28
" Modify: 2019-11-28

let g:vnite#command#clist#space = s:
let s:description = 'filter current error list'

" Func: #CR 
" error list line format may:
" <number> <file>:<line> col <col>:text
function! vnite#command#clist#CR(message) abort
    let l:text = a:message.text
    let l:text = substitute(l:text, '^\s*\d\+\s\+', '', 'g')
    let l:tokens = split(l:text, ':')
    let l:length = len(l:tokens)
    let l:filename = ''
    let l:line = 0
    let l:col = 0
    if l:length > 1
        let l:filename = l:tokens[0]
        let l:position = l:tokens[1]
        let l:line = 0 + l:position
        let l:col_str = matchstr(l:position, '\s\+col\s\+\zs\d\+\ze')
        if !empty(l:col_str)
            let l:col = 0 + l:col_str
        endif
        return printf('EditFLC %s %d %d', l:filename, l:line, l:col)
    else
        return ''
    endif
endfunction
