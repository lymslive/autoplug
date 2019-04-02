" File: zfold
" Author: lymslive
" Description: fold extention
" Create: 2019-04-01
" Modify: 2019-04-04

" toggle open/close fold
nnoremap <Space> :call zfold#cmd#nFold()<CR>
" create fold
vnoremap <Space> :call zfold#cmd#vFold()<CR>
onoremap <Space> :call zfold#cmd#oFold()<CR>

" create fold by tow regexp
command! -range -nargs=* -bang Z <line1>,<line2>call zfold#cmd#Fold(<bang>0, <f-args>)
command! -range -nargs=* -bang ZF <line1>,<line2>call zfold#cmd#FoldFull(<bang>0, <f-args>)

" load: 
function! zfold#plugin#load() abort "{{{
    return 1
endfunction "}}}
