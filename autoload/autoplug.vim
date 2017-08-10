" Class: autoplug
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-10
" Modify: 2017-08-10

if exists('s:load') && !exists('g:DEBUG')
    finish
endif
let s:load = 1

let s:path = expand('<sfile>:p:h')

" LOAD:
function! autoplug#load(...) abort "{{{
    if a:0 == 0
        return
    endif

    if empty(a:1)
        return
    endif

    if type(a:1) != type('')
        return
    endif

    if a:1 =~# '[/\]$'
        let l:name = substitute(a:1, '[/\]$', '')
    else
        let l:name = a:1
    endif

    try
        call {l:name}#plugin#load()
    catch 
        echoerr 'has no autoplug: ' . a:1
    endtry
endfunction "}}}

" complete: 
function! autoplug#complete(ArgLead, CmdLine, CursorPos) abort "{{{
    let l:lsGlob = glob(s:path . '/' . a:ArgLead . '*/', 0, 1)
    return map(l:lsGlob, 'fnamemodify(v:val, ":p:h:t")')
endfunction "}}}

command! -nargs=? -complete=customlist,autoplug#complete PI call autoplug#load(<f-args>)
