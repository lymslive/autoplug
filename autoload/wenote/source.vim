" list of viml script source file
" can also re-source at debug/devolop stage

" User Interface:
SOURCE config.vim  " custom maps, global variables
SOURCE plugin.vim  " define command and autocmd
SOURCE cmd.vim     " function wrapper for command

" Common Libs:
SOURCE lib/CListfile.vim

" Core Scripts:
SOURCE CBook.vim   " implement class of note book
SOURCE MBook.vim   " manage current note book
SOURCE MNote.vim   " manage current note buffer .md

" Clean: try to clean up at debug re-source
SOURCE cleanup.vim

" -------------------------------------------------------------------------------- "
finish
" -------------------------------------------------------------------------------- "
