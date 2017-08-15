" Wrap.vim
"   interfaces (options, maps, commands) of using Wrap
" Author: lymslive / 2016-08-30

" Load Control: {{{1
let s:thispath = fnamemodify(expand("<sfile>"), ":p:h")
if filereadable(s:thispath . '/' . 'setlocal.vim') 
    if fnamemodify(expand("<sfile>"), ":t:r") !=? 'setlocal'
        finish
    endif
endif

" 英文括号 "{{{1
nnoremap ,` <ESC>:call wraptext#func#wrap("`", "`", "n")<CR>
nnoremap ,' <ESC>:call wraptext#func#wrap("'", "'", "n")<CR>
nnoremap ," <ESC>:call wraptext#func#wrap('"', '"', "n")<CR>
nnoremap ,( <ESC>:call wraptext#func#wrap("(", ")", "n")<CR>
nnoremap ,[ <ESC>:call wraptext#func#wrap("[", "]", "n")<CR>
nnoremap ,< <ESC>:call wraptext#func#wrap("<", ">", "n")<CR>
nnoremap ,{ <ESC>:call wraptext#func#wrap("{", "}", "n")<CR>
nnoremap ,<Space> v<ESC>:call wraptext#func#wrap(" ", " ", "v")<CR>

vnoremap ,` <ESC>:call wraptext#func#wrap("`", "`", "v")<CR>
vnoremap ,' <ESC>:call wraptext#func#wrap("'", "'", "v")<CR>
vnoremap ," <ESC>:call wraptext#func#wrap('"', '"', "v")<CR>
vnoremap ,( <ESC>:call wraptext#func#wrap("(", ")", "v")<CR>
vnoremap ,[ <ESC>:call wraptext#func#wrap("[", "]", "v")<CR>
vnoremap ,{ <ESC>:call wraptext#func#wrap("{", "}", "v")<CR>
vnoremap ,< <ESC>:call wraptext#func#wrap("<", ">", "v")<CR>
vnoremap ,<Space> <ESC>:call wraptext#func#wrap(" ", " ", "v")<CR>

" 中文括号 "{{{1
nnoremap ,," <ESC>:call wraptext#func#wrap("“", "”", "n")<CR>
nnoremap ,,' <ESC>:call wraptext#func#wrap("‘", "’", "n")<CR>
nnoremap ,,( <ESC>:call wraptext#func#wrap("（", "）", "n")<CR>
nnoremap ,,) <ESC>:call wraptext#func#wrap("〔", "〕", "n")<CR>
nnoremap ,,< <ESC>:call wraptext#func#wrap("《", "》", "n")<CR>
nnoremap ,,> <ESC>:call wraptext#func#wrap("〈", "〉", "n")<CR>
nnoremap ,,[ <ESC>:call wraptext#func#wrap("【", "】", "n")<CR>
nnoremap ,,] <ESC>:call wraptext#func#wrap("［", "］", "n")<CR>
nnoremap ,,{ <ESC>:call wraptext#func#wrap("〖", "〗", "n")<CR>
nnoremap ,,} <ESC>:call wraptext#func#wrap("｛", "｝", "n")<CR>

vnoremap ,," <ESC>:call wraptext#func#wrap("“", "”", "v")<CR>
vnoremap ,,' <ESC>:call wraptext#func#wrap("‘", "’", "v")<CR>
vnoremap ,,( <ESC>:call wraptext#func#wrap("（", "）", "v")<CR>
vnoremap ,,) <ESC>:call wraptext#func#wrap("〔", "〕", "v")<CR>
vnoremap ,,< <ESC>:call wraptext#func#wrap("《", "》", "v")<CR>
vnoremap ,,> <ESC>:call wraptext#func#wrap("〈", "〉", "v")<CR>
vnoremap ,,[ <ESC>:call wraptext#func#wrap("【", "】", "v")<CR>
vnoremap ,,] <ESC>:call wraptext#func#wrap("［", "］", "v")<CR>
vnoremap ,,{ <ESC>:call wraptext#func#wrap("〖", "〗", "v")<CR>
vnoremap ,,} <ESC>:call wraptext#func#wrap("｛", "｝", "v")<CR>

" 插入模式 "{{{1
inoremap ` ``<Left>
inoremap ' ''<Left>
inoremap " ""<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap } {}
" inoremap ) ()
inoremap ] []

" load:  "{{{1
function! wraptext#plugin#load() abort "{{{
    return 1
endfunction "}}}
