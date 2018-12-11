" File: shell
" Author: lymslive
" Description: terminal shell tools
" Create: 2018-08-01
" Modify: 2018-08-01

" FindTermWin: 
" @argin a:1, the job run in terminal, default 'bash'
" @return winnr or [tabnr, winnr] if in another tabpage
" @return if not found
function! useterm#shell#FindTermWin(...) abort "{{{
    let l:jobname = get(a:000, 0, &shell)
    let l:count = winnr('$')
    for l:win in range(1, l:count)
        if getwinvar(l:win, '&buftype') ==# 'terminal'
            let l:bufnr = winbufnr(l:win)
            if bufname(l:bufnr) =~? l:jobname
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
                if bufname(l:bufnr) =~? l:jobname
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
function! useterm#shell#GotoTermWin(...) abort "{{{
    let l:jobname = get(a:000, 0, &shell)
    let l:target = useterm#shell#FindTermWin(l:jobname)
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

" SendShellCmd: 
" send a cmd to an existed terminal shell or open a new one
function! useterm#shell#SendShellCmd(bang, cmd) abort "{{{
    " save current window
    if a:bang
        let l:tab = tabpagenr()
        let l:win = winnr()
    endif

    let l:found = useterm#shell#GotoTermWin(&shell)
    if empty(l:found)
        :terminal
    endif
    if !empty(a:cmd)
        call term_sendkeys('', a:cmd . "\<CR>")
        " into insert mode in terminal window
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
