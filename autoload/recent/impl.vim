" implement of most recent list

let s:mrgroup = v:null

function! recent#impl#start() abort
    let l:datafile = ''
    s:mrgroup = recent#group#new(l:datafile)
endfunction

function! recent#impl#record() abort
endfunction

function! recent#impl#view() abort
endfunction
