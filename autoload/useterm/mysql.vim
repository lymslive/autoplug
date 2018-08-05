" File: mysql
" Author: lymslive
" Description: use mysql
" Create: 2018-07-16
" Modify: 2018-07-16

let s:mysql_prg = get(g:, 'useterm#mysql#prg', 'mysql')
let s:mysql_arg = get(g:, 'useterm#mysql#arg', '')
let s:mysql_user = get(g:, 'useterm#mysql#user', '')
let s:mysql_pass = get(g:, 'useterm#mysql#pass', '')
let s:mysql_host = get(g:, 'useterm#mysql#host', '') " 127.0.0.1
let s:mysql_port = get(g:, 'useterm#mysql#port', '') " 3306
let s:mysql_db = get(g:, 'useterm#mysql#db', '')

" BuildCmdline: 
function! s:BuildCmdline() abort "{{{
    let l:args = s:mysql_arg
    if !empty(s:mysql_host)
        let l:args .= ' -h ' . s:mysql_host
    endif
    if !empty(s:mysql_port)
        let l:args .= ' -P ' . s:mysql_port
    endif
    if !empty(s:mysql_user)
        let l:args .= ' -u ' . s:mysql_user
    endif
    if !empty(s:mysql_pass)
        let l:args .= ' -p' . s:mysql_pass
    endif
    if !empty(s:mysql_db)
        let l:args .= ' ' . s:mysql_db
    endif

    return s:mysql_prg . ' ' . l:args
endfunction "}}}

" QuickExecute: 
function! useterm#mysql#QuickExecute(sql, ...) abort "{{{
    let l:format = get(a:000, 0, 'B')
    let l:cmd = printf("%s -%se %s", s:BuildCmdline(), l:format, shellescape(a:sql))
    return system(l:cmd)
endfunction "}}}

" MysqlTable: 
function! useterm#mysql#MysqlTable(table) abort "{{{
    let l:sql = printf('desc %s; select count(*) from %s;', a:table, a:table)
    return useterm#mysql#QuickExecute(l:sql, 't')
endfunction "}}}
