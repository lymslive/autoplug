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
nnoremap ,` <ESC>:call Wrap#Wrap("`", "`", "n")<CR>
nnoremap ,' <ESC>:call Wrap#Wrap("'", "'", "n")<CR>
nnoremap ," <ESC>:call Wrap#Wrap('"', '"', "n")<CR>
nnoremap ,( <ESC>:call Wrap#Wrap("(", ")", "n")<CR>
nnoremap ,[ <ESC>:call Wrap#Wrap("[", "]", "n")<CR>
nnoremap ,< <ESC>:call Wrap#Wrap("<", ">", "n")<CR>
nnoremap ,{ <ESC>:call Wrap#Wrap("{", "}", "n")<CR>
nnoremap ,<Space> v<ESC>:call Wrap#Wrap(" ", " ", "v")<CR>

vnoremap ,` <ESC>:call Wrap#Wrap("`", "`", "v")<CR>
vnoremap ,' <ESC>:call Wrap#Wrap("'", "'", "v")<CR>
vnoremap ," <ESC>:call Wrap#Wrap('"', '"', "v")<CR>
vnoremap ,( <ESC>:call Wrap#Wrap("(", ")", "v")<CR>
vnoremap ,[ <ESC>:call Wrap#Wrap("[", "]", "v")<CR>
vnoremap ,{ <ESC>:call Wrap#Wrap("{", "}", "v")<CR>
vnoremap ,< <ESC>:call Wrap#Wrap("<", ">", "v")<CR>
vnoremap ,<Space> <ESC>:call Wrap#Wrap(" ", " ", "v")<CR>

" 中文括号 "{{{1
nnoremap ,," <ESC>:call Wrap#Wrap("“", "”", "n")<CR>
nnoremap ,,' <ESC>:call Wrap#Wrap("‘", "’", "n")<CR>
nnoremap ,,( <ESC>:call Wrap#Wrap("（", "）", "n")<CR>
nnoremap ,,) <ESC>:call Wrap#Wrap("〔", "〕", "n")<CR>
nnoremap ,,< <ESC>:call Wrap#Wrap("《", "》", "n")<CR>
nnoremap ,,> <ESC>:call Wrap#Wrap("〈", "〉", "n")<CR>
nnoremap ,,[ <ESC>:call Wrap#Wrap("【", "】", "n")<CR>
nnoremap ,,] <ESC>:call Wrap#Wrap("［", "］", "n")<CR>
nnoremap ,,{ <ESC>:call Wrap#Wrap("〖", "〗", "n")<CR>
nnoremap ,,} <ESC>:call Wrap#Wrap("｛", "｝", "n")<CR>

vnoremap ,," <ESC>:call Wrap#Wrap("“", "”", "v")<CR>
vnoremap ,,' <ESC>:call Wrap#Wrap("‘", "’", "v")<CR>
vnoremap ,,( <ESC>:call Wrap#Wrap("（", "）", "v")<CR>
vnoremap ,,) <ESC>:call Wrap#Wrap("〔", "〕", "v")<CR>
vnoremap ,,< <ESC>:call Wrap#Wrap("《", "》", "v")<CR>
vnoremap ,,> <ESC>:call Wrap#Wrap("〈", "〉", "v")<CR>
vnoremap ,,[ <ESC>:call Wrap#Wrap("【", "】", "v")<CR>
vnoremap ,,] <ESC>:call Wrap#Wrap("［", "］", "v")<CR>
vnoremap ,,{ <ESC>:call Wrap#Wrap("〖", "〗", "v")<CR>
vnoremap ,,} <ESC>:call Wrap#Wrap("｛", "｝", "v")<CR>

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
