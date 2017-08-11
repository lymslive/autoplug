" File: FKEY.vim
" Author: lymslive
" Description: some functions may bound to function key
" Last Modified: 2016-08-30

function! microcmd#FKEY#ReNameCurFile(name) "{{{
    if a:name == ""
        return
    endif
    let l:cname = expand('%')
    if l:cname == ""
        execute "write " . a:name
        return
    endif
    update
    if rename(l:cname, a:name) == 0
        execut "edit " . a:name
        bdelete #
    endif
endfunction " ReNameCurFile }}}
