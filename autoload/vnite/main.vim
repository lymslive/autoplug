" File: main
" Author: lymslive
" Description: main functions entrance
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#main#space = s:
let s:Context = vnite#Context#class()
let s:jLastContext = {}
let s:sMsgBufName = '_CMDMSG_'
let s:MessageBuffer = v:null

if !exists(':CM')
    command! -bang -count=0 -nargs=* -complete=command CM call vnite#main#run(<bang>0, <count>, <f-args>)
endif
let s:cmdopt = vnite#lib#Cmdopt#new('CM')
call s:cmdopt.addhead('Capture and filter message output of any command')
            \.addoption('smart', 's', 'only capture if the command can handled by vnite')
            \.endoption()
            \.addargument('cmd', 'the real command will execute')

" Func: #run 
" run a cmd and show in a buffer where can be filtered view
function! vnite#main#run(bang, count, ...) abort
    let l:options = s:cmdopt.parse(a:000)
    if empty(l:options) || l:options.help
        return s:cmdopt.usage()
    endif

    let l:count = -1
    let l:cmd = join(l:options.arguments, ' ')
    if empty(l:cmd)
        if a:count > 0
            let l:history = vnite#command#hotlist(a:count)
            if !empty(l:history)
                let l:cmd = l:history
                let l:count = a:count
            else
                echoerr 'no CM history number:' a:count
            endif
        else
            return s:show_message_window()
        endif
    endif

    if l:cmd =~# '^\s*CM\s\+'
        " protect accidently repeat :CM CM prefix
        execute l:cmd
        return
    endif

    let l:context = s:Context.new(l:cmd, s:get_message_buffer())
    if l:options.smart && !vnite#command#handled(l:context.command)
        execute l:cmd
        return
    endif

    call s:apply_config(l:context)
    let l:length = s:run_cmd(l:cmd, l:context)
    if l:length < 1
        return
    elseif l:length == 1 && len(l:context.messages[0]) < 80
        echo l:context.messages[0]
        return
    else
        let s:jLastContext = l:context
        call vnite#command#svaecmd(l:cmd, l:count)
        call s:show_message_window(s:jLastContext)
    endif

    let l:bFilter = l:context.config.start_filter
    if a:bang
        let l:bFilter = !l:bFilter
    endif
    if l:bFilter
        :StartFilter
    endif
endfunction

" Func: #cap 
" alike #run, but not show in buffer, only store  and return a context object
function! vnite#main#cap(cmd) abort
    let l:context = s:Context.new(a:cmd)
    let l:length = s:run_cmd(a:cmd, l:context)
    if l:length > 0
        return l:context
    else
        return v:null
    endif
endfunction

" Func: s:run_cmd 
" run the cmd, store output in context, return the lines of output
" return -1 if fail
function! s:run_cmd(cmd, context) abort
    let l:succ = v:true
    let l:output = ''
    try
        call vnite#command#precmd(a:cmd)
        let l:output = execute(a:cmd)
    catch 
        let l:succ = v:false
        echo "fail to run cmd: " .. v:exception
    finally
        call vnite#command#postcmd()
    endtry

    if !l:succ
        return -1
    endif

    let l:length = 0
    if !empty(g:vnite#command#space.output)
        let l:length = a:context.store(g:vnite#command#space.output)
    elseif !empty(l:output)
        let l:length = a:context.store(l:output)
    endif

    return l:length
endfunction

" Func: #statusline 
function! vnite#main#statusline() abort
    if empty(s:jLastContext)
        return &g:statusline
    endif
    let l:stl = 'CM ' . s:jLastContext.cmdline
    if !empty(s:jLastContext.simcli)
        let l:filter = join(s:jLastContext.simcli.cmdline, '')
        if s:jLastContext.simcli.active
            let l:sep = ' || '
        else
            let l:sep = ' | '
        endif
        let l:stl = l:filter . l:sep . l:stl
    endif
    let l:stl = l:stl . '%=%l/%L'
    return l:stl
endfunction

" Func: s:show_message_window 
" a:1, fill the window with new context
function! s:show_message_window(...) abort
    let l:buffer = s:get_message_buffer()
    call l:buffer.show()
    if a:0 <= 0 || empty(a:1)
        if !b:VniteContext.config.reserve_filter
            call b:VniteContext.simcli.clearall()
        endif
        return 0
    endif

    let l:context = a:1
    let b:VniteContext = l:context
    call l:buffer.setline(l:context.messages)
    if l:context.config.start_toend
        normal! G
    endif

    :nmapclear <buffer>
    call vnite#config#buffer_maps()
    let l:space = vnite#command#get_space(l:context)
    let l:actor = get(l:space, 'actor', {})
    if !empty(l:actor)
        call l:actor.bindmap()
    endif

    call clearmatches()
    call vnite#command#post_buffer(l:context)
endfunction

" Func: s:get_message_buffer 
function! s:get_message_buffer() abort
    if empty(s:MessageBuffer)
        let s:MessageBuffer = vnite#lib#Sbuffer#new(s:sMsgBufName, function('s:initMsgBuf'))
        let s:MessageBuffer.spcmd = s:split_cmd()
    endif
    return s:MessageBuffer
endfunction

" Func: s:initMsgBuf 
function! s:initMsgBuf() abort
    " setlocal filetype=cmdmsg
    setlocal statusline=%!vnite#main#statusline()
    call vnite#config#buffer_maps()
endfunction

" Func: s:split_cmd 
function! s:split_cmd() abort
    let l:height = 10
    if exists('g:vnite#config#winheight') && g:vnite#config#winheight > 0
        let l:height = g:vnite#config#winheight
    endif
    return printf('botright %d split', l:height)
endfunction

" Func: s:apply_config 
function! s:apply_config(context) abort
    if !has_key(a:context, 'config') || !empty(a:context.config)
        return
    endif
    let l:config = {}
    let l:space = vnite#command#get_space(a:context)
    call s:set_value(l:config, 'start_filter', l:space, 0)
    call s:set_value(l:config, 'reserve_filter', l:space, 1)
    call s:set_value(l:config, 'start_toend', l:space, 0)
    call s:set_value(l:config, 'keep_open', l:space, 0)
    let a:context.config = l:config
endfunction

" Func: set_value
function! s:set_value(config, name, space, default) abort
    if has_key(a:space, a:name)
        let a:config[a:name] = a:space[a:name]
    elseif exists('g:vnite#config#' . a:name)
        let a:config[a:name] = g:vnite#config#{a:name}
    else
        let a:config[a:name] = a:default
    endif
endfunction
