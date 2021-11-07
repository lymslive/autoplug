" File: shell
" Author: lymslive
" Description: terminal shell tools
" Create: 2018-08-01
" Modify: 2018-08-01

" SendShellCmd: 
" send a cmd to an existed terminal shell or open a new one
function! useterm#shell#SendShellCmd(bang, cmd) abort "{{{
    " save current window
    if a:bang
        let l:tab = tabpagenr()
        let l:win = winnr()
    endif

    let l:jobname = fnamemodify(&shell, ':t')
    let l:found = s:GotoTermWin(l:jobname)
    if empty(l:found)
        :terminal
    endif
    if !empty(a:cmd) && a:cmd !~# '^\s*$'
        call term_sendkeys('', a:cmd . "\<CR>")
        " into insert mode in terminal window, to redraw shell result
        normal! i
    endif

    " back to origin window
    if a:bang
        if l:tab != 0 && l:tab != tabpagenr()
            execute l:tab . 'tabnext'
        endif
        if l:win != 0 && l:win != winnr()
            execute l:win . 'wincmd w'
        endif
    endif
endfunction "}}}

" FindTermWin: 
" @argin a:1, the job run in terminal, default 'bash'
" @return winnr or [tabnr, winnr] if in another tabpage
" @return if not found
function! s:FindTermWin(...) abort "{{{
    let l:jobname = get(a:000, 0, &shell)
    let l:count = winnr('$')
    for l:win in range(1, l:count)
        if getwinvar(l:win, '&buftype') ==# 'terminal'
            let l:bufnr = winbufnr(l:win)
            if fnamemodify(bufname(l:bufnr), ':t') =~? l:jobname
                return l:win
            endif
        endif
    endfor

    let l:iTabOld = tabpagenr()
    for l:tab in range(1, tabpagenr('$'))
        if l:tab == l:iTabOld
            continue
        endif 
        : execute l:tab . 'tabnext'
        for l:win in range(1, tabpagewinnr(l:tab, '$'))
            if gettabwinvar(l:tab, l:win, '&buftype') ==# 'terminal'
                let l:bufnr = winbufnr(l:win)
                if fnamemodify(bufname(l:bufnr), ':t') =~? l:jobname
                    : execute l:iTabOld . 'tabnext'
                    return [l:tab, l:win]
                endif
            endif
        endfor
    endfor

    : execute l:iTabOld . 'tabnext'
    return 0
endfunction "}}}

" GotoTermWin: 
" like FindTermWin but also goto that window (and tabpage)
function! s:GotoTermWin(...) abort "{{{
    let l:jobname = get(a:000, 0, &shell)
    let l:target = s:FindTermWin(l:jobname)
    if empty(l:target)
        return 0
    endif
    if type(l:target) == type(0)
        let l:win = l:target
        if l:win != 0 && l:win != winnr()
            execute l:win . 'wincmd w'
        endif
        return l:win
    elseif type(l:target) == type([])
        let l:tab = get(l:target, 0, 0)
        let l:win = get(l:target, 1, 0)
        if l:tab != 0 && l:tab != tabpagenr()
            execute l:tab . 'tabnext'
            if l:win != 0 && l:win != winnr()
                execute l:win . 'wincmd w'
            endif
        endif
        return [l:tab, l:win]
    endif
endfunction "}}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Func: s:FindShellPwd 
" find current path in terminal shell, that may be different from vim's
function! s:FindShellPwd() abort
    if &buftype != 'terminal'
        return ''
    endif

    " last prompt line, eg:
    " lymslive@DESKTOP-KRJE2KE:~/winhome/Documents/github/$
    let l:psline = getline('$')
    let l:lsMatch = matchlist(l:psline, '^\s*.\{-}@.\{-}:\(.*\)\s*\$')
    if !empty(l:lsMatch)
        let l:pwd = l:lsMatch[1]
        return expand(l:pwd)
    endif

    " $ is in new line
    if l:psline =~ '^\s*\$'
        let l:psline = getline(line('$')-1)
    endif
    let l:lsMatch = matchlist(l:psline, '^\s*.\{-}@.\{-}:\(.*\)\s*\$')
    if !empty(l:lsMatch)
        let l:pwd = l:lsMatch[1]
        return expand(l:pwd)
    endif
endfunction

" Func: s:OpenFile 
" try to open file in another window from terminal, option a:1 is file line
" return 0 if file cannot open, 1 if succ
function! s:OpenFile(file, ...) abort
    if !filereadable(a:file)
        return 0
    endif
    let l:cmd = ''
    if winnr('$') > 1
        wincmd W
        let l:cmd = 'edit '
    else
        let l:cmd = 'split '
    endif
    let l:cmd .= a:file
    execute l:cmd
    if a:0 > 0 && a:1 =~ '^\d\+$'
        execute a:1
    endif
    if a:0 > 1 && a:2 =~ '^\d\+$'
        execute 'normal! ' . a:2 . '|'
    endif
    return 1
endfunction

" Func: s:PressEnter 
function! s:PressEnter() abort
    let l:pwd = s:FindShellPwd()
    if empty(l:pwd)
        return 0
    endif

    let l:line = getline('.')
    let l:word = expand('<cword>')
    let l:Word = expand('<cWORD>')

    " gcc make error line, eg:
    " file:line:column
    let l:lsMatch = matchlist(l:line, '^\([^:]\+\):\(\d\+\):\(\d\+\):')
    if !empty(l:lsMatch)
        let l:file = l:lsMatch[1]
        let l:lineNo = l:lsMatch[2]
        let l:columnNo = l:lsMatch[3]
        let l:file = l:pwd . '/' . l:file
        let l:ret = s:OpenFile(l:file, l:lineNo, l:columnNo)
        if l:ret
            return l:ret
        endif
    endif

    " ll output
    let l:lsMatch = matchlist(l:line, '^-[rwx]\{9\}\s\+.\{-}\(\S\+\)$')
    if !empty(l:lsMatch)
        let l:file = l:lsMatch[1]
        if l:file =~ '\*$'
            let l:file = strpart(l:file, 0, strlen(l:file)-1)
        endif
        let l:file = l:pwd . '/' . l:file
        let l:ret = s:OpenFile(l:file)
        if l:ret
            return l:ret
        endif
    endif

    " ls output
    let l:file = l:Word
    let l:file = l:pwd . '/' . l:file
    let l:ret = s:OpenFile(l:file)
    if l:ret
        return l:ret
    endif

    return 0
endfunction

" Func: #SmartEnter 
function! useterm#shell#SmartEnter() abort
    if s:PressEnter()
        return 1
    else
        " defalut: send cword to terminmer line, but not <CR>, left editable
        call term_sendkeys('', expand('<cword>'))
        normal! i
        return 0
    endif
endfunction
