" File: plugin
" Author: lymslive
" Description: debug viml
" Create: 2018-09-21
" Modify: 2018-09-21

function! debug#plugin#load() abort "{{{
    return 1
endfunction "}}}

" Command: DEBUG
function! s:debug(...) abort "{{{
    let l:on = get(a:000, 0, 1)
    let g:DEBUG = l:on
    if g:DEBUG > 0
        call debug#log#up(g:DEBUG)
    endif
endfunction "}}}
command! -nargs=? DEBUG call s:debug(<f-args>)
" DEBUG 1

SOURCE log.vim

" rename vim file, fix path#to#function
command! -nargs=* -complete=file VimRename call debug#rename#command(<f-args>)

" display an overview of a class, use full class name with #
command! -nargs=* -complete=file ClassView call debug#lookup#ClassView(<f-args>)

" :Test [-f filename] argument-list-pass-to-#test
" call the #test function of some script, default currnet file
" :Test! also execute :MessageView after :Test
command! -nargs=* -bang -complete=file Test call debug#test#command(<bang>0, <f-args>)

" display the last message in qf or local window
" :MessageView, display in special buffer window
command! -nargs=0 -count=10 MessageQ call debug#test#MessageRefix(<count>, 'qf')
command! -nargs=0 -count=10 MessageL call debug#test#MessageRefix(<count>, 'll')
command! -nargs=0 -count=10 MessageView call debug#message#view(<count>)

" open the log buffer window or message window
nnoremap g> :<C-u>LOGON<CR>
nnoremap g/ :<C-u>10MessageView<CR>

" :BreakFunc funcname [lineshift]
" add breakpoint in a function
" {funcname} can be s:funcname form, 
" then will search the output of ":function /" to get the real funcname
command! -nargs=+ BreakFunc call debug#break#func(<f-args>)

" ftvim: 
function! debug#plugin#ftvim() abort "{{{
    " setlocal iskeyword+=#
    " setlocal iskeyword+=:

    if exists('g:debug_ftplugin_autocmd')
        augroup EDIT_VIM
            autocmd! * <buffer>
            autocmd BufWritePre <buffer> call debug#rename#UpdateModity()
        augroup END
    endif

    nnoremap <buffer> <C-]> :call debug#lookup#GotoDefineFunc()<CR>

    " :B
    " :Break break at current line, parsing function context
    command! -nargs=* -buffer B call debug#break#command(<f-args>)
endfunction "}}}
