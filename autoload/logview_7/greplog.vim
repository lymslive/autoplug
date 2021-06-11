" File: logview
" Author: lymslive
" Description: 
" Create: 2021-05-23
" Modify: 2021-05-23

let s:bufname = '_GREPLOG_'
let s:grep_match_id = -1

" Func: #hGlog 
function! logview_7#greplog#hGlog(...) abort
    let l:word = ''
    if a:0 > 0 && !empty(a:1)
        let l:word = a:1
    else
        let l:word = expand('<cword>')
    endif
    if empty(l:word)
        echo 'Glog expect an argument, what to grep?'
        return 0
    endif

    let l:lines = []
    let l:iend = line('$')
    for l:linenr in range(1, l:iend)
        let l:strLine = getline(l:linenr)
        if l:strLine =~ l:word
            call add(l:lines, l:strLine)
        endif
    endfor

    if empty(l:lines)
        echo 'nothing to grep ' . l:word
        return 0
    endif

    if s:gotoGrepBuff() != -1
        1,$ delete
        call append(0, l:lines)
        normal! gg
        call clearmatches()
        let s:grep_match_id = matchadd('Search', l:word)
    endif
endfunction

" Func: s:createGrepBuff 
function! s:createGrepBuff() abort
    execute 'tabedit ' . s:bufname
    set buftype=nofile
    nnoremap q :q<CR>
    " nnoremap q :e #<CR>
    return bufnr('%')
endfunction

" Func: s:getGrepBuff 
function! s:getGrepBuff() abort
    let l:buf = bufnr(s:bufname)
    if l:buf == -1
        let l:buf = s:createGrepBuff()
    endif
    return l:buf
endfunction

" Func: s:gotoGrepBuff 
function! s:gotoGrepBuff() abort
    let l:buf = s:getGrepBuff()
    if l:buf == -1
        echo 'fail to locate and/or create the grep buffer'
        return -1
    endif
    if l:buf != bufnr('%')
        execute 'tabnew +buffer' . l:buf
        " execute 'buffer' . l:buf
    endif
    return l:buf
endfunction
