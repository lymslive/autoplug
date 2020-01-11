" File: VTag
" Author: lymslive
" Description: list built-in tags
" Create: 2019-11-29
" Modify: 2019-11-29

let g:vnite#command#VTag#space = s:

" VTag: list all tag lines from tagfiles()
" VTag %: list tag of current buffer
" VTag pattern: list tag filtered by pattern
if !exists(':VTag')
    command! -nargs=* -complete=tag VTag call vnite#command#VTag#run(<f-args>)
endif

let s:description = 'list built-in tags from &tags'

" Func: #run 
function! vnite#command#VTag#run(...) abort
    let l:tags = s:vtags(a:000)
    if empty(l:tags)
        return
    endif
    call vnite#command#output(l:tags)
endfunction

" Func: s:vtags 
function! s:vtags(argv) abort
    let l:tagfiles = tagfiles()
    if empty(l:tagfiles)
        return
    endif
    let l:result = []
    let l:pattern = ''
    if !empty(a:argv)
        let l:pattern = a:argv[0]
        if l:pattern == '%'
            let l:pattern = expand('%:t')
        endif
    endif
    for l:tagfile in l:tagfiles
        let l:lines = readfile(l:tagfile)
        if !empty(l:pattern)
            call filter(l:lines, {idx, val -> val =~ l:pattern})
        endif
        let l:start = s:skip_head(l:lines)
        call extend(l:result, l:lines[l:start : ])
    endfor
    return l:result
endfunction

" Func: s:skip_head 
" skip !_TAG_ head lines
function! s:skip_head(lines) abort
    let l:start = 0
    for l:idx in range(len(a:lines))
        if a:lines[l:idx] !~# '^!_TAG_'
            let l:start = l:idx
            break
        endif
    endfor
    return l:start
endfunction

" Func: #CR 
function! vnite#command#VTag#CR(message) abort
    let l:text = a:message.text
    let l:tag = matchstr(l:text, '^\s*\zs\S\+\ze')
    if !empty(l:tag)
        return 'tag ' . l:tag
    else
        return ''
    endif
endfunction
