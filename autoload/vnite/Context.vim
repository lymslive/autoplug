" File: Context
" Author: lymslive
" Description: Context class
" Create: 2019-10-31
" Modify: 2019-10-31

" Context handle the information about the command that will output messages
let s:class = {}
let s:class._ctype_ = 'Context'
let s:class.bufnr = 0         " the origin buffer number
let s:class.winid = 0         " the origin window id
let s:class.curfile = ''      " full path of current buffer
let s:class.curpos = []       " origin cursor position
let s:class.cmdline = ''      " full command line where message output from
let s:class.command = ''      " the command name, usually first word
let s:class.linebreak = "\n"  " message text seperate by \n default
let s:class.messages = []     " list of the output messages
let s:class.filtered = []     " list of the filtered messages current show
let s:class.simcli = v:null   " simulated cmdline to filter message
let s:class.config = v:null   " config for this command or global

" Func: #class 
function! vnite#Context#class() abort
    return s:class
endfunction

" Method: new 
function! s:class.new(cmdline) dict abort
    if empty(a:cmdline)
        return {}
    endif

    let l:object = copy(s:class)
    let l:object.bufnr = bufnr('%')
    let l:object.winid = bufwinid('%')
    let l:object.curfile = expand('%:p')
    let l:object.curpos = getcurpos()
    let l:object.cmdline = a:cmdline
    let l:object.command = s:extract_cmdname(a:cmdline)

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
    let l:winnr = bufwinnr(self.bufnr)
    let [l:tabnr, l:winnr] = win_id2tabwin(self.winid)
    if l:tabnr > 0 && l:winnr > 0
        execute l:tabnr . 'tabnext'
        execute l:winnr . 'wincmd w'
    else
        call s:find_main_window()
    endif
    if bufnr('%') ==  self.bufnr
        call setpos('.', self.curpos)
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

" Func: s:find_main_window 
function! s:find_main_window() abort
    let l:wincount = winnr('$')
    if l:wincount < 2
        return
    endif
    let l:maxarea = 0
    let l:mainwin = 0
    for l:winnr in range(1, l:wincount)
        let l:area = winwidth(l:winnr) * winheight(l:winnr)
        if l:area > l:maxarea
            let l:maxarea = l:area
            let l:mainwin = l:winnr
        endif
    endfor
    if l:mainwin > 0
        execute l:mainwin . 'wincmd w'
    endif
endfunction
