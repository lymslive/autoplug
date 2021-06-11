" File: logview
" Author: lymslive
" Description: 
" Create: 2021-05-21
" Modify: 2021-05-23

" Open Log File:
" open list log file with prefix/base name
" or list those files, or swith to nexe/prev log 
" support log file suffix with datetime
command! -nargs=+ -complete=customlist,logview_7#cmdu#complist Elog call logview_7#cmdu#hElog(<f-args>)
command! -nargs=+ -complete=customlist,logview_7#cmdu#complist ElogList call logview_7#cmdu#hElogList(<f-args>)
command! -nargs=*  ElogNext call logview_7#cmdu#hElogNext(<f-args>)
command! -nargs=*  ElogPrev call logview_7#cmdu#hElogPrev(<f-args>)

" Grep Log Lines:
" grep current log file, show result in new tabpage
command! -nargs=*  Glog call logview_7#greplog#hGlog(<f-args>)

" Func: #onftLOG 
function! logview_7#plugin#onftLOG() abort
    nnoremap <buffer> T :Glog <C-R><C-W><CR>
    vnoremap <buffer> T y:<C-U>Glog <C-R>"<CR>
    return 1
endfunction

" Func: #load 
function! logview_7#plugin#load() abort
    return 1
endfunction
