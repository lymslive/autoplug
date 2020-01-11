" File: action
" Author: lymslive
" Description: handdle actions on one message text
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#action#space = s:
let s:Message = vnite#Message#class()
let s:sActBufName = '_CMDACT_'

let s:error = ''

" Func: #run 
function! vnite#action#run(name, ...) abort
    let s:error = ''
    if !exists('b:VniteContext')
        echoerr 'not in vnite message buffer'
        return -1
    endif

    let l:message = s:get_message()
    let l:cmd = l:message.action(a:name)
    if empty(l:cmd)
        if !empty(s:error)
            let s:error = 'action not handled!'
        endif
        echohl WarningMsg
        echomsg s:error
        echohl None
        return 0
    endif

    " only show cmd that will excuted
    if a:0 > 0 && !empty(a:1)
        echo l:cmd
        return 0
    endif

    let l:context = b:VniteContext
    if !l:context.config.keep_open
        :quit
    endif
    call l:context.winback()
    execute l:cmd
    echo l:cmd
endfunction

" Func: #error 
function! vnite#action#error(msg) abort
    let s:error = a:msg
    return 0
endfunction

" Func: s:get_message 
function! s:get_message() abort
    let l:line = line('.')
    let l:text = getline('.')
    let l:index = b:VniteContext.orindex(l:line)
    let l:message = s:Message.new(b:VniteContext, l:text, l:index)
    if empty(l:message)
        echoerr 'fail to create Message oject'
        return {}
    endif
    return l:message
endfunction

" Method: buffer 
function! s:initActBuf() dict abort
    nnoremap <buffer> <CR> :call vnite#action#select()<CR>
    nnoremap <buffer> q    :quit<CR>
endfunction

let s:ActionBuffer = vnite#lib#Sbuffer#new(s:sActBufName, function('s:initActBuf'))
let s:ActionBuffer.spcmd = 'rightbelow vsplit'

" Func: #more 
function! vnite#action#more() abort
    if !exists('b:VniteContext')
        echoerr 'not in vnite message buffer'
        return -1
    endif
    let l:context = b:VniteContext
    let l:command = l:context.command
    let l:space = vnite#command#get_space(l:command)
    if empty(l:space) || !has_key(l:space, 'actor') || empty(l:space.actor)
        echo 'no other action supported for this command :' . l:command
        return -1
    endif

    let l:actor = l:space.actor
    let l:lines = l:actor.display()

    call s:ActionBuffer.show()
    call s:ActionBuffer.setline(l:lines)
    let b:ActionTable = l:actor
endfunction

" Func: #select 
function! vnite#action#select() abort
    if !exists('b:ActionTable')
        echoerr 'not in action table buffer?'
        return -1
    endif
    let l:line = getline('.')
    if l:line =~ '^#'
        echo 'please select a command below'
        return 0
    endif
    let l:tokens = split(l:line, '\s\+')
    if len(l:tokens) < 2
        echo 'not find valid action name in current line'
        return -1
    endif
    let l:action = l:tokens[1]
    if l:action =~? 'Default'
        let l:action = 'CR'
    endif

    let l:table = b:ActionTable
    :quit
    if exists('b:VniteContext')
        call vnite#action#run(l:action)
    else
        echo 'cancle action as message buffer seems closed'
    endif
endfunction

