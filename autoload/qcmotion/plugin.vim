" qcmotion.vim
"   interfaces (options, maps, commands) of using qcmotion
" Author: lymslive / 2016-08 / 2019-04

" nnoremap Q q
nnoremap <silent> Q :call qcmotion#func#NormalMove()<CR>
vnoremap <silent> Q :<C-u>call qcmotion#func#VisualMove()<CR>
onoremap <silent> Q :call qcmotion#func#OpendMove()<CR>

" load: 
function! qcmotion#plugin#load() abort "{{{ 1
    return 1
endfunction "}}}
