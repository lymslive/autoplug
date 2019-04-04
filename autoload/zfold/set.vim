" File: set
" Author: lymslive
" Description: settings for zfold
" Create: 2019-04-03
" Modify: 2019-04-03


let s:thispath = expand('<sfile>:p:h')
" echo s:thispath
" let g:zfold#set#json = json_decode(join(readfile(s:thispath . '/set.json'), ''))
let g:zfold#set#json = autoplug#jsonConfig('autoload/zfold/set.json', s:thispath . '/set.json')
