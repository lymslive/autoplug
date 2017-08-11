" qcmotion.vim
"   interfaces (options, maps, commands) of using qcmotion
" Author: lymslive / 2016-08

" Load Control: {{{ 1
let s:thispath = fnamemodify(expand("<sfile>"), ":p:h")
if filereadable(s:thispath . '/' . 'setlocal.vim') 
    if fnamemodify(expand("<sfile>"), ":t:r") !=? 'setlocal'
        finish
    endif
endif

nnoremap Q q
nnoremap <silent> q :call qcmotion#NormalMove()<CR>
vnoremap <silent> q :<C-u>call qcmotion#VisualMove()<CR>
onoremap <silent> q :call qcmotion#OpendMove()<CR>
