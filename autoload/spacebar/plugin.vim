" Spaceber.vim
"   interfaces (options, maps, commands) of using Spaceber
" Author: lymslive / 2016-08

" Load Control: {{{1
let s:thispath = fnamemodify(expand("<sfile>"), ":p:h")
if filereadable(s:thispath . '/' . 'setlocal.vim') 
    if fnamemodify(expand("<sfile>"), ":t:r") !=? 'setlocal'
        finish
    endif
endif

" Plugin Seeting: {{{1
" command define
command! -narg=?  Space call spacebar#func#SpaceModeSelect(<f-args>)

" Make \<Space> map, cycle switch the space mode.
noremap \<Space> :Space<CR>

" in ftplugin/cpp.vim
" call spacebar#SpaceModeSelect('Cpp')
" load: 
function! spacebar#plugin#load() abort "{{{
    return 1
endfunction "}}}
