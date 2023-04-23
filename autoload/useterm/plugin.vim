" File: plugin
" Author: lymslive
" Description: use terminal tools
" Create: 2018-07-16
" Modify: 2023-04-12

if has('terminal')
    tnoremap <Esc><Esc> <C-\><C-N>
    " tnoremap <Esc> <C-\><C-N>
    tnoremap <C-W>b <C-\><C-N><C-B>
    tnoremap <C-W>n <C-W>:tabnext<CR>
    tnoremap <C-W>N <C-W>:tabNext<CR>
    tnoremap <C-W>1 <C-W>:1tabNext<CR>
    tnoremap <C-W>2 <C-W>:2tabNext<CR>
    tnoremap <C-W>3 <C-W>:3tabNext<CR>
    tnoremap <C-W>4 <C-W>:4tabNext<CR>
    tnoremap <C-W>5 <C-W>:5tabNext<CR>
    tnoremap <C-W>6 <C-W>:6tabNext<CR>
    tnoremap <C-W>7 <C-W>:7tabNext<CR>
    tnoremap <C-W>8 <C-W>:8tabNext<CR>
    tnoremap <C-W>9 <C-W>:9tabNext<CR>
    tnoremap <C-W>0 <C-W>:$tabNext<CR>
endif

" Shell:
" send shell command to a terminal shell, open a new one if no terminal.
" may switch to another tabpage and/or window, but
" add `!` won't jump to the terminal window, actually jump back when done.
" Without no argument, just switch to terminal, and `!` will jump to current
" directory of editing buffer.
command! -nargs=* -bang -complete=file Shell call useterm#shell#SendShellCmd(<bang>0, <q-args>)

" ShellHere:
" make the terminal cd to current file directory from which this cmd executed.
" behave the same as `:Shell!`
command! -nargs=* ShellHere call useterm#shell#SendShellCmd(0, 'cd ' . expand('%:p:h'))

" MysqlTable:
" show basic information (desc and count(*)) of a table
command! -nargs=+ MysqlTable echo useterm#mysql#MysqlTable(<f-args>)
" MysqlExecute:
" like mysql -e 'sql statement' from shell cmdline
" 1st argument must be quoted 'sql statement'
" 2nd argument is optional switches pass to mysql, default -B
command! -nargs=+ MysqlExecute echo useterm#mysql#QuickExecute(<f-args>)

" load: 
function! useterm#plugin#load() abort "{{{
    if &buftype ==? 'terminal'
        cnoremap <buffer> <C-CR> <Home>Shell <End><CR>
        nnoremap <buffer> p :call term_sendkeys('', getreg())<CR>i
        vnoremap <buffer> p y:call term_sendkeys('', getreg())<CR>i
        nnoremap <buffer> s :Shell 
        " nnoremap <buffer> <CR> :Shell <C-R><C-W>
        nnoremap <buffer> <CR> :call useterm#shell#SmartEnter()<CR>
        vnoremap <buffer> <CR> y:Shell <C-R>=(visualmode() !=# 'v')? "" : getreg()<CR>

        nnoremap <buffer> [[ :call search('\$ ', 'b')<CR>
        nnoremap <buffer> ]] :call search('\$ ', '')<CR>

        nnoremap <buffer> ga :call term_sendkeys('', 'git add ' . expand('<cWORD>'))<CR>i

        echo 'terminal shell buffer remap take effect!'
    endif
    return 0
endfunction "}}}
