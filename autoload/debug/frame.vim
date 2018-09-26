" File: frame
" Author: lymslive
" Description: deal with <sfile> stack string
" Create: 2018-09-22
" Modify: 2018-09-22

let s:SLASH = fnamemodify('.', ':p')[-1:]
let s:PACK = package#import('package')

" backtrace: 
" remove the last {a:level} stacks in <sfile>
function! s:backtrace(level) abort "{{{
    let l:stacks = split(expand('<sfile>'), '\.\.')
    if len(l:stacks) > a:level
        let l:iend = len(l:stacks) - 1 - a:level
        let l:location = join(l:stacks[0: l:iend], '..')
    else
        let l:location = 'script'
    endif
    return l:location
endfunction "}}}

" stack_list: split <sfile> by ..
function! s:stack_list(sTrace) abort "{{{
    if a:sTrace !~# '^\s*function\s\+'
        return []
    endif
    let l:sTrace = substitute(a:sTrace, '^\s*function\s\+', '', '')
    let l:stacks = split(l:sTrace, '\.\.')
    return l:stacks
endfunction "}}}

" Func: s:func_line 
" split trace format "funcname[line]"
" return 2-item list [funcname line]
function! s:func_line(sTrace) abort "{{{
    if a:sTrace =~? '\[\d\+\]'
        let l:split = split(a:sTrace, '\[')
        return [l:split[0], 0+l:split[1]]
    else
        return [a:sTrace, 1]
    endif
endfunction "}}}

" stack_locat:
" try locate to stack intem string {function-name1}[{lnum}]
" the source script will load in the previous window if any.
function! s:stack_locate(sTrace) abort "{{{
    let [l:sFuncName, l:iFuncLine] = s:func_line(a:sTrace)
    if l:sFuncName =~# '#'
        return s:goto_sharp_func(l:sFuncName, l:iFuncLine)
    elseif l:sFuncName =~# 'SNR'
        return s:goto_sid_func(l:sFuncName, l:iFuncLine)
    else
        echoerr 'can only parse # or s: function'
    endif
endfunction "}}}

" goto_sharp_func: 
function! s:goto_sharp_func(sFuncName, iFuncLine) abort "{{{
    let l:split = split(a:sFuncName, '#')
    let l:sFuncName = remove(l:split, -1)
    let l:pFileName = join(l:split, s:SLASH) . '.vim'
    let l:lsVimfile = s:PACK.scripts()
    for l:idx in range(len(l:lsVimfile))
        if stridx(l:lsVimfile[l:idx], l:pFileName) != -1
            let l:pFilePath = l:lsVimfile[l:idx]
            break
        endif
    endfor

    if !exists(l:pFilePath) || empty(l:pFilePath)
        return
    endif

    :wincmd p
    execute 'hide edit ' . l:pFilePath
    if search(a:sFuncName, 'scew') && !empty(a:iFuncLine)
        execute 'normal! ' . (0+a:iFuncLine) . 'j'
    endif 
endfunction "}}}

function! s:goto_sid_func(sFuncName, iFuncLine) abort "{{{
    let l:lsMatch = matchlist(a:sFuncName, '<SNR>\(\d\+\)_\(\S\+\)')
    if len(l:lsMatch) < 2+1
        echoerr 'Invalid s:function format: ' . a:sFuncName
    endif
    let l:iSID = l:lsMatch[1]
    let l:sFuncName = l:lsMatch[2]

    let l:lsVimfile = s:PACK.scripts()
    let l:pFilePath = l:lsVimfile[l:iSID-1]

    :wincmd p
    execute 'hide edit ' . l:pFilePath
    let l:sPattern = '^\s*function!\?\s\+%s\>'
    let l:sPattern = printf(l:sPattern, 's:' . l:sFuncName)
    if search(l:sPattern, 'scew') && !empty(a:iFuncLine)
        execute 'normal! ' . (0+a:iFuncLine) . 'j'
    endif 
endfunction "}}}
