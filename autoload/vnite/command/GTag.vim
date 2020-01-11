" File: GTag
" Author: lymslive
" Description: list and filter tags using Gtags
" Create: 2019-11-29
" Modify: 2019-11-29

let g:vnite#command#GTag#space = s:

if !exists(':GTag')
    command! -nargs=* -complete=custom,vnite#command#GTag#complete GTag call vnite#command#GTag#run(<f-args>)
endif

let s:description = 'list tags for current buffer or project by gtags'
let s:cmdopt = vnite#lib#Cmdopt#new('Tag')
call s:cmdopt.addhead(s:description)
            \.addoption('all', 'c', 'complete all tags in project')
            \.addoption('Path', 'P', 'list files in project')
            \.endoption()

let s:actor = vnite#Actor#new('GTag')
call s:actor.add('Default', 'CR', 'default to tag position')

" Func: #run 
function! vnite#command#GTag#run(...) abort
    if !executable('global')
        call s:Error('command global not available, please check install gtags')
    endif
    let l:tags = s:gtags(a:000)
    if empty(l:tags)
        return
    endif
    call vnite#command#output(l:tags)
endfunction

" Func: s:gtags 
function! s:gtags(argv) abort
    if empty(a:argv)
        let l:file = expand('%')
        let l:cmd = 'global -f ' . shellescape((l:file))
    else
        let l:cmd = 'global -x ' . join(a:argv, ' ')
    endif
    let l:result = systemlist(l:cmd)
    if v:shell_error != 0
        if v:shell_error != 0
            if v:shell_error == 2
                call s:Error('invalid arguments. please use the latest GLOBAL.')
            elseif v:shell_error == 3
                call s:Error('GTAGS not found.')
            else
                call s:Error('global command failed. command line: ' . l:cmd)
            endif
        endif
        return
    endif
    if empty(l:result)
        call s:Error('Tag not found')
        return
    endif
    return l:result
endfunction

function! s:Error(msg)
    echohl WarningMsg | echomsg 'Error: ' . a:msg | echohl None
endfunction

" Func: #CR 
function! vnite#command#GTag#CR(message) abort
    let l:text = a:message.text
    let l:struct = s:parse(l:text)
    if !empty(l:struct.file)
        if l:struct.tag =~? 'path' && l:struct.line == 1
            " for gtas -P
            return printf('edit %s', l:struct.file)
        else
            return printf('EditFLC %s %d', l:struct.file, l:struct.line)
        endif
    else
        if filereadable(l:struct.tag)
            return printf('edit %s', l:struct.tag)
        else
            return printf('tag %s', l:struct.tag)
        endif
    endif
endfunction

let s:struct = {}
let s:struct.tag = ''
let s:struct.line = 0
let s:struct.file = ''
let s:struct.text = ''

" Func: s:parse 
" assuem symbol and filename not contain space
function! s:parse(text) abort
    let l:struct = copy(s:struct)
    let l:text = substitute(a:text, '^\s*\d\+\s\+', '', 'g')
    let l:text = substitute(l:text, '\s*$', '', 'g')
    if l:text =~# '^\w\+$'
        " only symbol tag
        let l:struct.tag = l:text
    else
        let l:match = matchlist(l:text, '^\(\w\+\)\s\+\(\d\+\)\s\+\(\S\+\)')
        if !empty(l:match)
            let l:struct.tag = l:match[1]
            let l:struct.line = l:match[2]
            let l:struct.file = l:match[3]
        endif
    endif
    return l:struct
endfunction

" Func: #complete 
function! vnite#command#GTag#complete(lead, line, pos) abort
    return system('global ' . '-c' . ' ' . a:lead)
endfunction
