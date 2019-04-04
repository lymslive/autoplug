" File: zfold
" Author: lymslive
" Description: fold extention
" Create: 2019-04-01
" Modify: 2019-04-04

" toggle open/close fold: za zf% zj
nnoremap <Space> :call zfold#cmd#nFold()<CR>
" create fold on selected range: zf
vnoremap <Space> :call zfold#cmd#vFold()<CR>

" Z: create fold by any argument conbination
" :Z /start/ /end/ /match/~ /nomatch/! /toggle/= /sibling/== /child/=>
" :Z /start/+ /end/-
" :Z $ $1 $name
command! -range -nargs=* -bang -complete=customlist,zfold#cmd#FoldCompl
            \ Z <line1>,<line2>call zfold#cmd#Fold(<bang>0, <f-args>)

set foldmethod=manual

" load: 
function! zfold#plugin#load() abort "{{{
    return 1
endfunction "}}}

finish
========================================
" TODO:
onoremap <Space> :call zfold#cmd#oFold()<CR>
command! -range -nargs=* -bang ZF <line1>,<line2>call zfold#cmd#FoldFull(<bang>0, <f-args>)
