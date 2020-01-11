" File: plugin
" Author: lymslive
" Description: PI message
" Create: 2019-10-30
" Modify: 2019-10-30

" :CM [options] [--] real_command
" capture the output of real command in a special message buffer
" short for `Command Message`
command! -bang -count=0 -nargs=* -complete=command CM call vnite#main#run(<bang>0, <count>, <f-args>)

" :EditFLC file line col
" edit a file with up to three argument
command! -nargs=+ -complete=file EditFLC call vnite#helper#edit3(<f-args>)

" :Vnite
" list all command that suit for CM prefix command
command! -nargs=* -complete=custom,vnite#command#Vnite#complete Vnite call vnite#command#Vnite#run(<f-args>)

" :StartFilter
" start filter mode on current buffer, named after :startinsert
command! -nargs=0 StartFilter call vnite#filter#start()

" :Fnoremap [<buffer>] {lhs} {rhs}
" :Funremap {lhs}
" map/unmap for Filter Mode
" simply the same as cnoremap, but not support complex arguments
" {lhs} must one key, support <Left> notation alike
command! -nargs=* Fnoremap call vnite#filter#noremap(<f-args>)
command! -nargs=1 Funremap call vnite#filter#unremap(<f-args>)

call vnite#config#load()

" custome commands can be used by CM
command! -nargs=* -complete=file File call vnite#command#File#run(<f-args>)

" Func: #load 
function! vnite#plugin#load() abort
    return 1
endfunction

" -------------------------------------------------------------------------------- "
finish
