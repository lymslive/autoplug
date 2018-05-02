" File: golang
" Author: lymslive
" Description: golang ftplugin
" Create: 2018-04-28
" Modify: 2018-04-29

" 包级块移动搜索
nnoremap <buffer> gm <Esc>:call golang#motion#Start('import', 'm', 'b')<CR>
nnoremap <buffer> [c <Esc>:call golang#motion#Start('const', 'm', 'b')<CR>
nnoremap <buffer> ]c <Esc>:call golang#motion#Start('const', 'm', '')<CR>
nnoremap <buffer> [v <Esc>:call golang#motion#Start('var', 'm', 'b')<CR>
nnoremap <buffer> ]v <Esc>:call golang#motion#Start('var', 'm', '')<CR>
nnoremap <buffer> [f <Esc>:call golang#motion#Start('func', 'm', 'b')<CR>
nnoremap <buffer> ]f <Esc>:call golang#motion#Start('func', 'm', '')<CR>
nnoremap <buffer> [s <Esc>:call golang#motion#Start('struct', 'm', 'b')<CR>
nnoremap <buffer> ]s <Esc>:call golang#motion#Start('struct', 'm', '')<CR>
nnoremap <buffer> [t <Esc>:call golang#motion#Start('interface', 'm', 'b')<CR>
nnoremap <buffer> ]t <Esc>:call golang#motion#Start('interface', 'm', '')<CR>

" nnoremap <buffer> q <Esc>:call golang#motion#Next()<CR>
" nnoremap <buffer> Q <Esc>:call golang#motion#Prev()<CR>

" 命令行引用包
command! -nargs=1 -complete=dir IM call golang#insertion#ImportSmart(<f-args>)
" inoremap <buffer> <expr> <CR> golang#insertion#EnterInsert()
" inoremap <buffer> <expr> <Esc> golang#insertion#EscapeInsert()
inoremap <buffer> <CR> <C-o>:call golang#insertion#EnterInsert()<CR><CR>
inoremap <buffer> <Esc> <C-o>:call golang#insertion#EscapeInsert()<CR><Esc>
