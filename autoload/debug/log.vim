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
let s:LOGBUFFER_NAME = '[VIMLOG]'

" :LOGON      |" start to log to a vim buffer
" :LOGON file |" start go log to file
" :LOGOFF     |" stop to log to buffer or buffer, default to message
function! debug#log#on(...) abort "{{{
    if a:0 == 0
        let l:bufnr = s:logbuffer()
        return s:loger.log_file('%' . l:bufnr)
    else
        return s:loger.log_file(a:1)
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
function! debug#log#command(msg, level, style) abort "{{{
    let l:time = strftime("%Y%m%d %T")
    if a:level < len(s:LEVEL_NAME)
        let l:label = s:LEVEL_NAME[a:level]
    else
        let l:label = s:LEVEL_NAME[-1]
    endif
    let l:stack = s:backtrace(2)
    let l:msg = printf('[%s][%s](%s) %s', l:time, l:label, l:stack, a:msg)
    call s:loger.log(l:msg, a:level, a:style)
endfunction "}}}

command! -nargs=+ -count=0 LOG call debug#log#command(eval(<q-args>), <count>, 'Comment')
command! -nargs=+ ELOG call debug#log#command(eval(<q-args>), 0, 'ErrorMsg')
command! -nargs=+ DLOG call debug#log#command(eval(<q-args>), 1, 'WarningMsg')
command! -nargs=+ WLOG call debug#log#command(eval(<q-args>), 2, 'WarningMsg')
command! -nargs=+ -count=0 SLOG call debug#log#command(<q-args>, <count>, 'Comment')

" create_logbuffer: 
function! s:logbuffer() abort "{{{
    if exists('s:LOGBUFFER') && !empty(s:LOGBUFFER)
        return s:LOGBUFFER
    endif

    let l:buffer = package#import('ly#buffer')
    let s:LOGBUFFER = l:buffer.auxbuffer(s:LOGBUFFER_NAME, {'filetype': 'log'}, s:mesmap)

    return s:LOGBUFFER
endfunction "}}}
