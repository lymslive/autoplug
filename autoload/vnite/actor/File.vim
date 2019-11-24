" File: File
" Author: lymslive
" Description: actor class for File command and alike
" Create: 2019-11-13
" Modify: 2019-11-13

let s:class = vnite#Actor#new('File')
call s:class.add('Default', 'CR', 'default to open')
            \.add('Split', 's', 'edit in new split window')
            \.add('Vsplit', 'S', 'edit in new vsplit window')
            \.add('Tabedit', 'T', 'edit in new tabpage')
            \.add('Delete', 'D', 'delete the file')
            \.add('Rename', 'R', 'rename the file')
            \.add('Chdir', 'C', 'lcd to the directory')

" Func: #new 
function! vnite#actor#File#new(...) abort
    let l:object = deepcopy(s:class)
    if a:0 > 0 && type(a:1) == v:t_func
        let l:object.parser = a:1
    else
        let l:object.parser = function('s:parser')
    endif
    return l:object
endfunction

" Func: s:parser 
function! s:parser(message) abort
    return a:message.text
endfunction

" Method: CR 
function! s:class.CR(message) dict abort
    let l:filename = self.parser(a:message)
    return 'edit ' . l:filename
endfunction

" Method: Split 
function! s:class.Split(message) dict abort
    let l:filename = self.parser(a:message)
    return 'split ' . l:filename
endfunction

" Method: Vsplit 
function! s:class.Vsplit(message) dict abort
    let l:filename = self.parser(a:message)
    return 'vsplit ' . l:filename
endfunction

" Method: Tabedit 
function! s:class.Tabedit(message) dict abort
    let l:filename = self.parser(a:message)
    return 'tabedit ' . l:filename
endfunction

" Method: Delete 
function! s:class.Delete(message) dict abort
    let l:filename = self.parser(a:message)
    if delete(l:filename) != 0
        echo 'fail to delete file: ' . l:filename
    endif
    return ''
endfunction

" Method: Rename 
function! s:class.Rename(message) dict abort
    let l:filename = self.parser(a:message)
    let l:bufnr = bufnr(l:filename)
    let l:newfile = input('rename to: ', '', 'file')
    if l:newfile !~ '^/' && l:newfile !~? '^[a-z]:\\'
        let l:newfile = l:dir . '/' . l:newfile
    endif
    if filereadable(l:newfile)
        echo 'target file already exists: ' . l:newfile
        return ''
    endif
    if rename(l:filename, l:newfile) != 0
        echo 'fail to rename file'
        return ''
    endif
    if l:bufnr > 0
        execute 'bdelete ' . l:bufnr
    endif
    return ''
endfunction

" Method: Chdir 
function! s:class.Chdir(message) dict abort
    let l:filename = self.parser(a:message)
    let l:dir = fnamemodify(l:filename, ':p:h')
    return 'lcd ' . l:dir
endfunction
