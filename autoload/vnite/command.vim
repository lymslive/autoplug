" File: command
" Author: lymslive
" Description: manager vnite command executed by CM
" Create: 2019-11-10
" Modify: 2019-11-10

let g:vnite#command#space = s:
let s:hotcmds = vnite#lib#Circle#new(get(g:, 'g:vnite#config#hotcmds', 10))
let s:running = v:false
let s:output = []

" Func: #precmd 
function! vnite#command#precmd(cmd) abort
    let s:running = v:true
    let s:output = []
endfunction

" Func: #postcmd 
function! vnite#command#postcmd() abort
    let s:running = v:false
endfunction

" Func: #svaecmd 
function! vnite#command#svaecmd(cmd, history_number) abort
    if a:history_number >= 0
        call s:hotcmds.rotate(a:history_number)
    else
        call s:hotcmds.push(a:cmd)
    endif
endfunction

" Func: #output 
function! vnite#command#output(list) abort
    if s:running
        let s:output = a:list
    else
        echo join(a:list, "\n")
    endif
endfunction

" Func: #history 
function! vnite#command#hotlist(...) abort
    if a:0 > 0 && type(a:1) == v:t_number
        return s:hotcmds.get(a:1)
    endif
    return s:hotcmds.list()
endfunction

" Func: #handled 
function! vnite#command#handled(command) abort
    if empty(a:command)
        return v:false
    endif
    if has_key(g:vnite#config#sharecmd, a:command)
        return v:true
    endif

    let l:file = printf('autoload/vnite/command/%s.vim', a:command)
    return !empty(findfile(l:file, &rtp))
endfunction

" Func: #get_space 
function! vnite#command#get_space(command) abort
    try
        if type(a:command) == v:t_string
            let l:command = a:command
        elseif type(a:command) == v:t_dict
            let l:command = a:command.transfer_command_name()
        endif
        let l:space = g:vnite#command#{l:command}#space
    catch 
        let l:space = {}
    endtry
    return l:space
endfunction

" Func: #post_buffer 
function! vnite#command#post_buffer(context) abort
    let l:command = a:context.transfer_command_name()
    let l:func = 'vnite#command#' . l:command . '#' . 'PostBuffer'
    if exists('*' . l:func)
        call call(function(l:func), [a:context])
    else
        let l:space = vnite#command#get_space(l:command)
        if has_key(l:space, 'PostBuffer') && type(l:space.PostBuffer) == v:t_func
            call l:space.PostBuffer(a:context)
        endif
    endif
endfunction
