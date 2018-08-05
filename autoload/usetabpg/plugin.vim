" usetab.vim
"   interfaces (options, maps, commands) of using tabpage
" lymslive / 2016-03

" Control Load: {{{1
" if 'setlocal.vim' exists in the same path, don't load this script,
" using the users interface code instead
" You can directly modify this file, or :saveas a copy to 'setlocal.vim'
" BUT WITHOUT this block
let s:thispath = fnamemodify(expand("<sfile>"), ":p:h")
if filereadable(s:thispath . '/' . 'setlocal.vim')
    " echomsg "read setlocal, skip this file!"
    finish
endif

" Option Setting: {{{1
" custom tabline with much useful indicative information
if !exists('$SPACEVIM')
    set tabline=%!usetabpg#func#CustTabLine()
endif
" don't use GUI tabline
" set guioptions-=e

" Command Interface: {{{1
" :T -- jump to the alternative tabpage which is last visited
" :[count]T or :T[count] -- jump to the [count]th tabpage
command! -nargs=* -count=0 T call usetabpg#func#jumpalt(<count>, <f-args>)

" Remap Interface: {{{1
" *gt* is mainly does the same thing as :T, in normal mode.
" :help gt to see the default gt behavior
nnoremap gt :call usetabpg#func#jumpalt()<CR>
nnoremap gT :tabnew<CR>
if has('terminal')
    tnoremap <C-W>t <C-W>:call usetabpg#func#jumpalt()<CR>
endif

" *gn* directly jump to the n-th tabpage
" :help g8 :help g0 to see the default behavior
nnoremap g1 :tabnext 1<CR>
nnoremap g2 :tabnext 2<CR>
nnoremap g3 :tabnext 3<CR>
nnoremap g4 :tabnext 4<CR>
nnoremap g5 :tabnext 5<CR>
nnoremap g6 :tabnext 6<CR>
nnoremap g7 :tabnext 7<CR>
nnoremap g9 :tabnext 8<CR>
nnoremap g9 :tabnext 9<CR>
nnoremap g0 :tabnext 10<CR>

" jkhl movement with tabpage
nnoremap gh :tabfirst<CR>
nnoremap gj :tabnext<CR>
nnoremap gk :tabprevious<CR>
nnoremap gl :tablast<CR>

" load: {{{1
function! usetabpg#plugin#load() abort "{{{
    return 1
endfunction "}}}
