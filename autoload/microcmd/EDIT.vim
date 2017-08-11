" File: EDIT.vim
" Author: lymslive
" Description: functions in edit mode, inser or cmdline mode
" Last Modified: 2016-08-30

cnoremap <C-k> <C-\>emicrocmd#EDIT#CKillLine()<CR>
function! microcmd#EDIT#CKillLine() "{{{
    let l:cmd = getcmdline()
    let l:rem = strpart(l:cmd, getcmdpos() - 1)
    if ('' != l:rem)
        let @c = l:rem
    endif
    let l:ret = strpart(l:cmd, 0, getcmdpos() - 1)
    return l:ret
endfunction "}}}
function! microcmd#EDIT#CKillWord() "{{{
    let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:roc = strpart(getcmdline(), getcmdpos() - 1)
    if (l:roc =~ '\v^\s*\w')
        let l:rem = matchstr(l:roc, '\v^\s*\w+')
    elseif (l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]')
        let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
    elseif (l:roc =~ '\v^\s+$')
        let @c = l:roc
        return l:loc
    else
        return getcmdline()
    endif
    let @c = l:rem
    let l:ret = l:loc . strpart(l:roc, strlen(l:rem))
    return l:ret
endfunction "}}}

function! microcmd#EDIT#IKillWord() "{{{
    if col('.') > strlen(getline('.'))
        return "\<Del>\<C-o>dw"
    else
        return "\<C-o>dw"
    endif
endfunction "}}}
inoremap <C-k> <C-r>=microcmd#EDIT#IKillLine()<CR>
function! microcmd#EDIT#IKillLine() "{{{
    if col('.') > strlen(getline('.'))
        return "\<Del>"
    else
        return "\<C-o>d$"
    endif
endfunction "}}}
