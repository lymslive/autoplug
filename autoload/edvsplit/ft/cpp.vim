" ED.vim ftplugin for cpp

let s:thispath = fnamemodify(expand("<sfile>"), ":p:h")
if filereadable(s:thispath . '/' . 'setlocal.vim') 
    if fnamemodify(expand("<sfile>"), ":t:r") !=? 'setlocal'
	finish
    endif
endif

" nnoremap <buffer> <CR> :call HCPP#SwitchFunctionDef()<CR>

" default map for <CR>
" nnoremap : <C-R>=expand("<cword>")<CR><Home>
nnoremap <silent> <buffer> <CR> @=HCPP#SwitchFunctionDef() == 1 ? '^f(' : ':' . expand("<cword>")<CR>
