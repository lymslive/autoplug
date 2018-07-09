" MicroCommand.vim
"   interfaces (options, maps, commands) of this plugin
" Author: lymslive / 2016-08-27

" Load Control: 
let s:thispath = fnamemodify(expand("<sfile>"), ":p:h")
if filereadable(s:thispath . '/' . 'setlocal.vim') 
    if fnamemodify(expand("<sfile>"), ":t:r") !=? 'setlocal'
        finish
    endif
endif

" Command: {{{1

" EV: edit a vim file in any runtimepaths
" empty argument, edit $MYVIMRC
" `EV .` a dot argument , edit ftplugin with current filetype
command! -nargs=? -complete=customlist,microcmd#EV#Complist EV call microcmd#EV#Commander(<f-args>)

" H: help a topic
" default topic is <cword>, can use -number to reuse history topic
command! -nargs=? -complete=help H call microcmd#HELP#Commander('', <f-args>)
" HV HT: see help topic in vertical splited or new tab window
command! -nargs=? -complete=help HV call microcmd#HELP#Commander('vertical', <f-args>)
command! -nargs=? -complete=help HT call microcmd#HELP#Commander('tab', <f-args>)
" HH: help on last topic
command! -nargs=0 HH call microcmd#HELP#Commander('', -1)

" SET: toogle some settings
command! -nargs=* -complete=option SET call microcmd#SET#Toogle(<f-args>)

" P: special paste command
" no args: P = `normal! p` or  P! = `normal! P`
" one args: register x use `p`, -x use `P`, ! is after normal
command! -nargs=? -bang P call microcmd#PASTE#Commander("<bang>", <f-args>)

" open terminal in new tabpage or vertical split window
command! -nargs=* TT tab terminal <args>
command! -nargs=* TV vertical terminal <args>

" Remap: {{{1
" Toogle Set Maps:
nnoremap \s :SET<CR>
nnoremap \r :SET readonly<CR>
nnoremap \a :SET clipboard autoselect<CR>
nnoremap \c :SET cmdheight 1 2<CR>
nnoremap \i :SET selection inclusive exclusive<CR>
nnoremap \n :SET number<CR>
nnoremap \p :SET paste<CR>
nnoremap \w :SET wrap<CR>
nnoremap \z :SET foldlevel 0 99<CR>
nnoremap \v :call microcmd#SET#Toogle('virtualedit', "", 'all')<CR>

inoremap <F2> <C-R>=expand('%:r')<CR>
nnoremap <F1> :exec "help ". expand("<cword>")<CR>
nnoremap <F2> :echo(expand('%:p'))<CR>
nnoremap <F3> :buffers<CR>:buffer<Space>
nnoremap <F4> :wa<Bar>exe "mksession! " . v:this_session
nnoremap <F5> :e<CR>
vnoremap <F1> y:<C-\>e (visualmode() != 'v')? "help index" : "help " . getreg()<CR><CR>
vnoremap <F2> s<C-R>=expand('%:t')<CR>

" Load: {{{1
" load: 
function! microcmd#plugin#load() abort
    return 1
endfunction
