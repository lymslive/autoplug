" manage recent opened file globally, grouped by filetype(.ext)
"

command -nargs=* Recent call recent#impl#view(<f-args>)

augroup AUTO_RECENT
    autocmd!
    autocmd BufRead,BufWrite * call recent#impl#record(<afile>)
augroup END

call recent#impl#start()

function! recent#plugin#load()
    return 1
endfunction
