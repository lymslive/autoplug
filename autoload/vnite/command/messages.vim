" File: messages
" Author: lymslive
" Description: load message in vnite buffer
" Create: 2019-12-24
" Modify: 2019-12-24

let g:vnite#command#messages#space = s:
let s:description = 'load message in vnite buffer, may help debug'
let s:actor = vnite#Actor#new('messages')
call s:actor.add('Break', 'B', 'add bread point here')

let s:pattern = {}
let s:pattern.funcstack = '^Error detected .* function \zs\S\+\ze:$'
let s:pattern.funcline = '^line\s\+\zs\d\+\ze:$'
let s:pattern.errormsg = '^E\d\+\ze:\s\+'
let s:pattern.stacksep = '\.\.'
let s:pattern.func_with_line = '\(\S\+\)\[\(\d\+\)\]'

let s:pattern.exception = '^Exception caught:'

" Func: #CR 
" a:message is vnite object
function! vnite#command#messages#CR(message) abort
    let l:dStack = s:parse_stack(a:message)
    if empty(l:dStack)
        return ''
    endif
    let l:stack = s:get_cursor_stack(l:dStack)
    if empty(l:stack)
        return ''
    endif

    if l:stack.func =~# '^\d\+'
        return vnite#action#error('can not locate anonymous function')
    endif

    let l:function = g:vnite#command#function#space
    let l:from = l:function.Where(l:stack.func)
    if empty(l:from)
        return ''
    else
        let l:file = l:from.file
        let l:line = l:from.line + l:stack.line
        return 'EditFLC ' .. l:file .. ' ' .. l:line
    endif
endfunction

" Func: #Break
function! vnite#command#messages#Break(message) abort
    let l:dStack = s:parse_stack(a:message)
    if empty(l:dStack)
        return ''
    endif
    let l:stack = s:get_cursor_stack(l:dStack)
    if empty(l:stack)
        return ''
    endif

    let l:cmd = printf('breakadd func %d %s', l:stack.line, l:stack.func)
    echo l:cmd
endfunction

" Func: #PostBuffer 
function! vnite#command#messages#PostBuffer(context) abort
    call matchadd('ErrorMsg', s:pattern.funcstack)
    call matchadd('ErrorMsg', s:pattern.errormsg)
    call matchadd('ErrorMsg', s:pattern.exception)
    normal! G
endfunction

" Func: s:parse_stack 
function! s:parse_stack(message) abort
    let l:text = a:message.text
    let l:obj = {}
    let l:full_name = matchstr(l:text, s:pattern.funcstack)
    if empty(l:full_name)
        return {}
    endif

    let l:stacks = split(l:full_name, s:pattern.stacksep)
    let l:length = len(l:stacks)
    if l:length > 1
        let l:idx = 0
        while l:idx < l:length - 1
            let l:stack = l:stacks[l:idx]
            let l:matchs = matchlist(l:stack, s:pattern.func_with_line)
            if len(l:matchs) > 2
                let l:func = l:matchs[1]
                let l:line = l:matchs[2]
                " change function[line] string to dict
                let l:stack = {'func': l:func, 'line': l:line}
                let l:stacks[l:idx] = l:stack
            endif
            let l:idx += 1
        endwhile
    endif
    if l:length > 0
        let l:stack = {}
        let l:stack.func = l:stacks[-1]
        let l:stack.line = s:last_funcline(a:message)
        let l:stacks[-1] = l:stack
    endif

    let l:obj.full_name = l:full_name
    let l:obj.stacks = l:stacks
    return l:obj
endfunction

" Func: s:last_funcline 
function! s:last_funcline(message) abort
    let l:idx = a:message.index
    let l:context = a:message.context
    let l:next_line = get(l:context.messages, l:idx + 1, '')
    if empty(l:next_line)
        return 1
    endif
    let l:line = matchstr(l:next_line, s:pattern.funcline)
    if !empty(l:line)
        return 0 + l:line
    endif
    return 1
endfunction

" Func: s:get_cursor_stack 
" a:dStack is pre-parsed object, try to find cursor is on which stack
" or if cursor is on the head raw string, return the last stack
function! s:get_cursor_stack(dStack) abort
    let l:text = getline('.')
    if l:text !~# s:pattern.funcstack
        return v:null
    endif

    let l:col = col('.')
    let l:left = l:col
    let l:right = l:col
    let l:end = len(l:text) + 1

    let l:start = stridx(l:text, 'function ')
    if l:start < 0
        return v:null
    endif

    if empty(a:dStack.stacks)
        return v:null
    endif

    let l:last_stack = a:dStack.stacks[-1]
    let l:start += len('function ')
    if l:col == 1 || l:col < l:start || l:col >= l:end
        return l:last_stack
    endif

    " if cursor just on '..', back on stack
    let l:char = l:text[l:col-1]
    if l:char ==# '.'
        while l:char ==# '.' && l:col > 1
            let l:col -= 1
            let l:char = l:text[l:col-1]
        endwhile
        let l:right = l:col
    endif

    " move right bound
    let l:char = l:text[l:right-1]
    while l:right < l:end
        let l:next_char = l:text[l:right+1-1]
        if l:next_char ==# '.' || l:next_char ==# ':'
            break
        else
            let l:right += 1
        endif
    endwhile

    " move left bound
    let l:char = l:text[l:left-1]
    while l:left > 1
        let l:prev_char = l:text[l:left-1-1]
        if l:prev_char ==# '.' || l:prev_char ==# ' '
            break
        else
            let l:left -= 1
        endif
    endwhile

    let l:word = l:text[l:left-1 : l:right-1]
    let l:func = substitute(l:word, '\[\d\+\]$', '', 'g')
    for l:stack in a:dStack.stacks
        if l:stack.func ==# l:func
            return l:stack
        endif
    endfor
    return l:last_stack
endfunction

" -------------------------------------------------------------------------------- "

" Func: s:test 
function! s:test() abort
    call vnite#command#messages#CR({})
endfunction

" Func: #test 
function! vnite#command#messages#test() abort
    "
    call s:test()
endfunction
