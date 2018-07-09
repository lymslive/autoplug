" File: logjson
" Author: lymslive
" Description: 
" Create: 2018-07-09
" Modify: 2018-07-09

" SimpleBreak: 
" break a long json line and indent simplly,
" suppose cursor on such line.
function! tailflow#logjson#SimpleBreak() abort "{{{
    let l:iLine = line('.')
    let l:sLine = getline('.')
    if l:sLine !~ '{.*}'
        return
    endif

    " break at { and ,
    : substitute/[{,]\zs\s*/\r/g
    " go back origin line
    execute l:iLine
    normal f{=%
endfunction "}}}
