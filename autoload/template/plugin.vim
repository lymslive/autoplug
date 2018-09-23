function! template#plugin#load() abort "{{{
    return 1
endfunction "}}}

" Generate class frame code from template class file.
" :ClassNew will create a new file;
" :ClassAdd append code to current buffer;
" will check the current filename or directory required under autoload/
" :ClassTemp load frame code to current buffer without check filename
"
" They all accpet option to filt the template, and
" :ClassNew must provide a name before option.
" :ClassTemp -a option read in full template file, 
"  and the file itself list default option for each paragraph
command! -nargs=+ ClassNew call template#class#hClassNew(<f-args>)
command! -nargs=* ClassAdd call template#class#hClassAdd(<f-args>)
command! -nargs=* ClassTemp call template#class#hClassTemp(<f-args>)

" :ClassPart only add the sepecific paragraph subject it's option
" ignore the default option in the tempcall file
command! -nargs=1 ClassPart call template#class#hClassPart(<f-args>)

