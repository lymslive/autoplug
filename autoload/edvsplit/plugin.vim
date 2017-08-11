" ED.vim
"   interfaces (options, maps, commands) of using tow windows
" Author: lymslive / 2016-03

" Name Explain
" Load Control: {{{ 1
let s:thispath = fnamemodify(expand("<sfile>"), ":p:h")
if filereadable(s:thispath . '/' . 'setlocal.vim') 
    if fnamemodify(expand("<sfile>"), ":t:r") !=? 'setlocal'
	finish
    endif
endif

" Map Define UI: {{{1
" the maped rhs is uer defined commands, see the next section

" \e just make tow window edit the same file
nnoremap \e :E<CR>
nnoremap \E :D<CR>
" or edit the alternative file in one of the window
" nnoremap \e :EA<CR>
" nnoremap \E :DA<CR>
" edit tow alt-file with the filename under cursor
" ommit <CR> in map let you modify cmdline before execute
" nnoremap \E :ED expand('<cword>')

" jump to tag in the other window
nnoremap <C-w><C-]> :Dtag <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-w><C-t> :Dpop<CR>

" copy the current line or visual marked lines to the other window
nnoremap \p :Dcopy<CR>
nnoremap \P :Dmove<CR>
vnoremap \p :<C-u>Dcopy v<CR>
vnoremap \P :<C-u>Dmove v<CR>

" edit alt-file, in current window
nnoremap \a :A<CR>
nnoremap \A :vsplit<CR>:A<CR>

" Command Define: {{{1
command! -nargs=* E call edvsplit#ED#EditAnother(<f-args>)
command! -nargs=* D call edvsplit#ED#CmdInAnother(<f-args>)
command! -nargs=1 -complete=tag Dtag call edvsplit#ED#TagInAnother(<q-args>)
command! Dpop call edvsplit#ED#PopInAnother()
command! -nargs=? Dcopy call edvsplit#ED#CopyToAnother(<q-args>)
command! -nargs=? Dmove call edvsplit#ED#MoveToAnother(<q-args>)

command! -nargs=* EA call edvsplit#ED#EditAltOfAnother(<f-args>)
command! -nargs=* DA call edvsplit#ED#EditAltInAnother(<f-args>)
command! -nargs=+ -complete=file_in_path ED call edvsplit#ED#EditInDouble(<f-args>)

" if use a.vim the :A command may confict
" command! -nargs=* AA call edvsplit#AB#EditAltFile(expand("%:p"), <f-args>)
command! -nargs=* A call edvsplit#AB#EditAltFile(expand("%:p"), <f-args>)
command! -nargs=* AE call edvsplit#AB#EditAltFile(<f-args>)

" File Type Plugin: {{{1

" onft: 
function! edvsplit#plugin#onft(fn, ft) abort "{{{
    nnoremap <silent> <buffer> <CR> @=HCPP#SwitchFunctionDef() == 1 ? '^f(' : ':' . expand("<cword>")<CR>
endfunction "}}}

augroup EDVSPLIT
    autocmd!
    autocmd filetype *.cpp,*.c,*.h call edvsplit#plugin#onft(<afile>, <amatch>)
augroup END
