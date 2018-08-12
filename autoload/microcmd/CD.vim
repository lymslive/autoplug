" File: CD
" Author: lymslive
" Description: more powerful cd command
" Create: 2018-08-12
" Modify: 2018-08-12

" https://github.com/wting/autojump
let s:autojump = executable('autojump')

" Commander: 
function! microcmd#CD#Commander(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        lcd $VIMHOME
    elseif a:0 == 1
        if a:1 == '?'
            if s:autojump
                return s:AutojumpState()
            endif
        elseif a:1 == '/'
            let l:rtp = class#less#rtp#export()
            let l:prj = l:rtp.FindPrject('.')
            if empty(l:prj)
                ELOG 'can not find project root'
            else
                execute 'lcd' l:prj
                echo l:prj
            endif
            return
        elseif a:1 == '.'
            lcd %:p:h
            echo expand('%:p:h')
        elseif a:1 == '-'
            lcd -
        else
            return s:VimhomeCD(a:1) || s:AutojumpCD(a:1) || s:DefaultCD(a:1)
        endif
    elseif a:0 > 1
        if s:autojump
            return s:AutojumpCDMulti(a:000)
        endif
    endif
endfunction "}}}

" Autojump: 
" capture output of `autojump`
function! microcmd#CD#Autojump(...) abort "{{{
    if !s:autojump
        return
    endif
    let l:cmd = 'autojump ' . join(a:000, ' ')
    let l:outplut = system(l:cmd)
    if v:shell_error
        return ''
    endif
    return l:outplut
endfunction "}}}
if s:autojump
    command! -nargs=+ Autojump echo microcmd#CD#Autojump(<f-args>)
endif

" VimhomeCD: 
function! s:VimhomeCD(path) abort "{{{
    if empty($VIMHOME)
        return v:false
    endif
    let l:rtp = class#less#rtp#export()
    let l:full = l:rtp.AddPath($VIMHOME, a:path)
    if isdirectory(l:full)
        execute lcd l:full
        return v:true
    else
        return v:false
    endif
endfunction "}}}

" AutojumpCD: 
" autojump with single argument as: j path
function! s:AutojumpCD(path) abort "{{{
    let l:auto = microcmd#CD#Autojump(a:path)
    if empty(l:auto)
        return v:false
    endif
    execute 'lcd' l:auto
    return v:true
endfunction "}}}

" AutojumpCDMulti: 
" use autojump with multiple arguments 
function! s:AutojumpCDMulti(args) abort "{{{
    let l:auto = call('microcmd#CD#Autojump', a:args)
    if empty(l:auto)
        return v:false
    endif
    execute 'lcd' l:auto
    return v:true
endfunction "}}}

" AutojumpState: 
function! s:AutojumpState() abort "{{{
    let l:outplut = microcmd#CD#Autojump('-s')
    echo l:outplut
endfunction "}}}

" DefaultCD: 
function! s:DefaultCD(path) abort "{{{
    let l:old = getcwd()
    execute 'lcd' a:path
    let l:new = getcwd()
    if l:new !=# l:old
        call microcmd#CD#Autojump('-a', l:new)
        return v:true
    else
        return v:false
    endif
endfunction "}}}
