" File: config
" Author: lymslive
" Description: global config for wenote
" Create: 2019-12-02
" Modify: 2019-12-02

let g:wenote#config#default_notebook = '~/notebook'

" Func: #notebuff 
function! wenote#config#notebuff() abort
    " AutoSave:
    command! -buffer NoteSave call wenote#cmd#NoteSave()
    augroup WENOTE_BUFFER
        autocmd! * <buffer>
        autocmd BufWritePost <buffer> NoteSave
    augroup END

    " <C-X><C-U> complete to insert tag
    setlocal completefunc=wenote#complete#InsertTag

    command! -buffer -nargs=* NoteJump call wenote#cmd#NoteJump(<f-args>)
    nnoremap <buffer> <C-]> :NoteJump<CR>

    nnoremap <buffer> <C-n> :NoteNew!<CR>
    nnoremap <buffer> <C-p> :CM -- NoteList<CR>
endfunction
