" File: plugin
" Author: lymslive
" Description: wenote, next version for my vnote
" Create: 2019-12-02
" Modify: 2019-12-02

" NoteBook:
" no argument, show (and save) the current notebook
" only with !, close (and save) current notebook
" with one argument, switch to that directory as current notebook
command! -nargs=? -bang -complete=dir 
            \ NoteBook call wenote#cmd#NoteBook(<bang>0, <f-args>)

" NoteNew:
" :NoteNew[!] tag1 tag2 ... # title string at last
" edit a new note with today path, add on note number, that is:
" yyyymmdd_<n+1>.md
" with! auto add tags based on current note
command! -nargs=* -bang -complete=customlist,wenote#complete#NoteNew
            \ NoteNew call wenote#cmd#NoteNew(<bang>0, <f-args>)

" NoteEdit:
" :NoteEdit noteid
command! -nargs=*  -complete=customlist,wenote#complete#NoteEdit
            \ NoteEdit call wenote#cmd#NoteEdit(<f-args>)

" NoteList:
" :NoteList [date|tag|any-key-word]
" will try to load list from three place in turn: 
" memery list, notelist file, glob *.md notes
command! -nargs=* -complete=customlist,wenote#complete#NoteList
            \ NoteList call wenote#cmd#NoteList(<f-args>)

" NoteTag:
" list used tags and corresponding note count
command! -nargs=* NoteTag call wenote#cmd#NoteTag(<f-args>)

" NoteScan:
" scan notebook to rebuild notelist, with ! save immediately
command! -nargs=* -bang NoteScan call wenote#cmd#NoteScan(<bang>0, <f-args>)

augroup WENOTE_GLOBAL
    autocmd!
    autocmd BufReadPost *.md,*.MD call wenote#cmd#NoteDetect()
    autocmd VimLeavePre * silent call wenote#cmd#NoteBook('close')
augroup END

" Func: #load 
function! wenote#plugin#load() abort
    return 1
endfunction

