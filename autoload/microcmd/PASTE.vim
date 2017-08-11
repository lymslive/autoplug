" PASTE.vim
" special past command
" Author: lymslive / 2016-08-29

function! microcmd#PASTE#Commander(bang, ...) " {{{1
    if a:0 == 0 || empty(a:1)
        if empty(a:bang)
            normal! p
        else
            normal! P
        endif
        return 1
    endif

    let l:arg = a:1
    if l:arg[0] == '-'
        let l:putcmd = 'P'
        let l:reg = l:arg[1]
    else
        let l:putcmd = 'p'
        let l:reg = l:arg[0]
    endif

    let l:cmd = 'normal' . a:bang . ' ' . l:reg . l:putcmd
    execute l:cmd
    return 2
endfunction
