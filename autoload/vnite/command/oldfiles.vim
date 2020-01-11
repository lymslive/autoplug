" File: oldfiles
" Author: lymslive
" Description: action for oldfiles
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#command#oldfiles#space = s:
let s:description = 'list all files stored in viminfo, CR to open one'

" Func: #CR 
function! vnite#command#oldfiles#CR(message) abort
    let l:text = a:message.text
    let l:file = matchstr(l:text, '^\s*\d\+:\s*\zs.\+\ze')
    if empty(l:file)
        echoerr 'the output seems not a numbered list of file as "%d: %f"'
        return ''
    endif
    return 'edit ' . l:file
endfunction
