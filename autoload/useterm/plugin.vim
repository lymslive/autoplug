" File: plugin
" Author: lymslive
" Description: use terminal tools
" Create: 2018-07-16
" Modify: 2018-07-16

if has('terminal')
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

command! -nargs=+ MysqlTable echo useterm#mysql#MysqlTable(<f-args>)
command! -nargs=+ MysqlExecute echo useterm#mysql#MysqlExecute(<f-args>)

" load: 
function! useterm#plugin#load() abort "{{{
    return 0
endfunction "}}}
