" File: Context
" Author: lymslive
" Description: Context class
" Create: 2019-10-31
" Modify: 2019-10-31

" Context handle the information about the command that will output messages
let s:class = {}
let s:class._ctype_ = 'Context'
let s:class.cmdline = ''      " full command line where message output from
let s:class.command = ''      " the command name, usually first word
let s:class.linebreak = "\n"  " message text seperate by \n default
let s:class.messages = []     " list of the output messages
let s:class.filtered = []     " list of the filtered messages current show
let s:class.simcli = v:null   " simulated cmdline to filter message
let s:class.sbuffer = v:null  " the associated special beffer
let s:class.config = v:null   " config for this command or global

" Func: #class 
function! vnite#Context#class() abort
    return s:class
endfunction

" Method: new 
function! s:class.new(cmdline, ...) dict abort
    if empty(a:cmdline)
        return {}
    endif

    let l:object = copy(s:class)
    let l:object.cmdline = a:cmdline
    let l:object.command = s:extract_cmdname(a:cmdline)
    if a:0 > 0 && !empty(a:1)
        let l:object.sbuffer = a:1
    endif

    let l:object.messages = []
    let l:object.filtered = []
    return l:object
endfunction

" Method: store 
function! s:class.store(output) dict abort
    if empty(a:output)
        return 0
    endif
    if type(a:output) == v:t_string
        let self.messages = split(a:output, self.linebreak)
    elseif type(a:output) == v:t_list
        let self.messages = a:output
    else
        echoerr 'can only store message in string or list form'
        return 0
    endif
    return len(self.messages)
endfunction

" Method: is_external_command 
function! s:class.is_external_command() dict abort
    return self.command =~# '^!'
endfunction
" Method: is_internal_command 
function! s:class.is_external_command() dict abort
    return self.command =~# '^[a-z]\+$'
endfunction

" Method: transfer_command_name 
function! s:class.transfer_command_name() dict abort
    let l:cmd = self.command
    let l:share = get(g:vnite#config#sharecmd, l:cmd, '')
    if !empty(l:share)
        let l:cmd = l:share
    endif
    return substitute(l:cmd, '^!', '_', '')
endfunction

" Method: winback 
" go back to the position before the command executed
function! s:class.winback() dict abort
    if !empty(self.sbuffer)
        call self.sbuffer.back_from()
    endif
endfunction

" Method: orindex 
" find the origin index of full list messages for some line in filtered buffer
function! s:class.orindex(line) dict abort
    if type(a:line) != v:t_number || a:line <= 0
        return 0
    endif

    if empty(self.filtered)
        return a:line - 1
    endif

    if a:line > self.filtered->len()
        return -1
    else
        return self.filtered[a:line-1]
    endif
endfunction

" -------------------------------------------------------------------------------- "

" Func: s:extract_cmdname 
function! s:extract_cmdname(cmdline) abort
    let l:lsWord= split(a:cmdline, '\s\+')
    let l:first = l:lsWord[0]
    let l:command = matchstr(l:first, '[!a-zA-Z][a-zA-Z0-9_]\+')
    if !empty(l:command)
        return l:command
    endif
    echoerr 'Invalid command name in the first word of cdmline'
    return ''
endfunction

