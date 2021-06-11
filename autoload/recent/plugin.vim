" manage recent opened file globally, grouped by filetype(.ext)
"

command -nargs=* Recent call recent#impl#view(<f-args>)

augroup AUTO_RECENT
    autocmd!
    autocmd BufRead,BufWrite * call recent#impl#record(expand('<afile>:p'))
    autocmd VimLeave * call recent#impl#save()
augroup END

call recent#impl#start()
call vnite#config#linkcmd('Recent', 'File', 'recent opened file/dir')

function! recent#plugin#load()
    return 1
endfunction
