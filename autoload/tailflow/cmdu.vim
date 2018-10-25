" File: cmdu
" Author: lymslive
" Description: 
" Create: 2018-06-04
" Modify: 2018-06-04

" Start: 
" :Tail file [--comand ...] [--and ...] [--not ...]
" {file} must appear first before any option
" each option [-c|a|n] accept multiply words as arguent list,
" until next option.
function! tailflow#cmdu#hStart(...) abort "{{{
    " complex argument parse
    let l:jOption = class#viml#cmdline#new('Tail')
    call l:jOption.AddMore('c', 'cmd', 'the command and its option', [])
    call l:jOption.AddMore('a', 'and', 'the regexp match list', [])
    call l:jOption.AddMore('n', 'not', 'the regexp not match list', [])

    let l:iErr = l:jOption.ParseCheck(a:000)
    if l:iErr != 0
        echo l:jOption.ShowUsage()
        return l:iErr
    endif

    let l:lsCmd = l:jOption.Get('cmd')
    let l:lsAnd = l:jOption.Get('and')
    let l:lsNot = l:jOption.Get('not')
    let l:lsPost = l:jOption.GetPost()
    if empty(l:lsPost) || empty(l:lsPost[0])
        :ELOG 'Tail must expect a file name'
        return -1
    endif

    " create object
    let l:file = l:lsPost[0]
    if !filereadable(l:file)
        echoerr 'file not exists:' l:file
        return -1
    endif
    let l:jFlow = tailflow#CFlow#new(l:file)

    " additional options
    if !empty(l:lsCmd)
        call l:jFlow.SetCommand(l:lsCmd)
    endif
    if !empty(l:lsAnd)
        call l:jFlow.SetAndList(l:lsAnd)
    endif
    if !empty(l:lsNot)
        call l:jFlow.SetNotList(l:lsNot)
    endif

    if 0 != l:jFlow.Start()
        return -1
    endif

    call l:jFlow.OpenBuffer()
    if !exists('b:jFlow')
        let b:jFlow = l:jFlow
        call tailflow#onft#Flow()
    endif
endfunction "}}}

" Func: #complist 
function! tailflow#cmdu#complist(ArgLead, CmdLine, CursorPos) abort "{{{
    let l:lsFile = glob(a:ArgLead . '*', 0, 1)
    call reverse(sort(l:lsFile))
    return l:lsFile
endfunction "}}}
