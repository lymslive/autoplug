" File: log
" Author: lymslive
" Description: log command interface
" Create: 2018-09-22
" Modify: 2018-09-22

let s:MLOG = package#import('class#viml#loger')
let s:loger = s:MLOG.instance()
let s:backtrace = package#imports('debug#frame', 'backtrace')
let s:mesmap = package#imports('debug#message', 'mesmap')

let s:LEVEL_NAME = ['ERR', 'DBG', 'WARN', 'INFO']
let s:LOGBUFFER_NAME = '.VIMLOG.buf'
let s:LOGBUFFER_HEIGHT = 15

" :LOGON      |" start to log to a vim buffer
" :LOGON file |" start go log to file
" :LOGOFF     |" stop to log to buffer or buffer, default to message
function! debug#log#on(...) abort "{{{
    if a:0 == 0
        let l:bufnr = s:logbuffer()
        call s:loger.log_file('%' . l:bufnr)
        call s:go_logwin()
    else
        call s:loger.log_file(a:1)
    endif
endfunction "}}}
command! -nargs=? -complete=file LOGON call debug#log#on(<f-args>)
command! -nargs=0 LOGOFF call debug#log#on('')

" :LOGUP level |" set the log level
function! debug#log#up(level) abort "{{{
    return s:loger.log_level(0 + a:level)
endfunction "}}}
command! -nargs=1 LOGUP call debug#log#up(<f-args>)

" command: 
function! debug#log#command(notrace, msg, level, style) abort "{{{
    let l:time = strftime("%Y%m%d %T")
    if a:level < len(s:LEVEL_NAME)
        let l:label = s:LEVEL_NAME[a:level]
    else
        let l:label = s:LEVEL_NAME[-1]
    endif
    if a:notrace
        let l:msg = printf('[%s][%s] %s', l:time, l:label, a:msg)
    else
        let l:stack = s:backtrace(2)
        let l:msg = printf('[%s][%s](%s) %s', l:time, l:label, l:stack, a:msg)
    endif
    call s:loger.log(l:msg, a:level, a:style)
endfunction "}}}

command! -nargs=+ -bang -count=0 LOG call debug#log#command(<bang>0, eval(<q-args>), <count>, 'Comment')
command! -nargs=+ -bang ELOG call debug#log#command(<bang>0, eval(<q-args>), 0, 'ErrorMsg')
command! -nargs=+ -bang DLOG call debug#log#command(<bang>0, eval(<q-args>), 1, 'WarningMsg')
command! -nargs=+ -bang WLOG call debug#log#command(<bang>0, eval(<q-args>), 2, 'WarningMsg')
command! -nargs=+ -bang -count=0 SLOG call debug#log#command(<bang>0, <q-args>, <count>, 'Comment')

" create_logbuffer: 
function! s:logbuffer() abort "{{{
    if exists('s:LOGBUFFER') && !empty(s:LOGBUFFER)
        return s:LOGBUFFER
    endif

    let l:buffer = package#import('cn#buffer')
    let s:LOGBUFFER = l:buffer.auxbuffer(s:LOGBUFFER_NAME, {'filetype': 'log'}, s:mesmap)

    return s:LOGBUFFER
endfunction "}}}

" Func: s:go_logwin 
function! s:go_logwin() abort "{{{
    let l:wincur = winnr()

    let l:winnr = bufwinnr(s:logbuffer())
    if l:winnr == -1
        botright split
        execute 'buffer' s:logbuffer()
        if winheight(0) > s:LOGBUFFER_HEIGHT
            execute 'resize' s:LOGBUFFER_HEIGHT
        endif
        let l:winnr = bufwinnr(s:logbuffer())
    endif

    if l:winnr != -1 && l:winnr != l:wincur
        execute l:winnr . 'wincmd w'
    endif

    return l:winnr
endfunction "}}}
