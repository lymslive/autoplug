
let g:vnite#command#history#space = s:
let s:description = 'list vim command history'
let s:start_toend = 1

" Func: #CR 
" the raw output of :history like below:
" >   132  CM history
function! vnite#command#history#CR(message) abort
    let l:text = a:message.text
    let l:text = substitute(l:text, '^>\?\s*\d\+\s*', '', '')
    return l:text
endfunction
