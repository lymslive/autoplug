" Class: autoplug
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-10
" Modify: 2017-08-15

if exists('s:load') && !exists('g:DEBUG')
    finish
endif
let s:load = 1

let s:path = expand('<sfile>:p:h')

" Command:
" :PI xxx yyy zzz
function! autoplug#load(...) abort "{{{
    if a:0 == 0
        return
    endif

    if empty(a:1)
        return
    endif

    for l:name in a:000
        if type(l:name) != type('')
            continue
        endif
        if l:name =~# '[/\]$'
            let l:name = substitute(l:name, '[/\]$', '')
        endif

        try
            call {l:name}#plugin#load()
        catch 
            echomsg 'has no autoplug: ' . l:name
            continue
        endtry
    endfor
endfunction "}}}

" Complete: 
function! autoplug#complete(ArgLead, CmdLine, CursorPos) abort "{{{
    let l:lsGlob = glob(s:path . '/' . a:ArgLead . '*/', 0, 1)
    let l:lsGlob= map(l:lsGlob, 'fnamemodify(v:val, ":p:h:t")')
    if s:path !=# expand('~/.vim/autoload')
        let l:path = expand('~/.vim/autoload')
        let l:lsMore = glob(l:path . '/' . a:ArgLead . '*/', 0, 1)
        let l:lsMore = map(l:lsMore, 'fnamemodify(v:val, ":p:h:t")')
        call extend(l:lsGlob, l:lsMore)
    endif
    return l:lsGlob
endfunction "}}}

command! -nargs=* -complete=customlist,autoplug#complete PI call autoplug#load(<f-args>)
