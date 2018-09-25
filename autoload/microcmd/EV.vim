" EV.vim
"   implement (functions) of this plugin
" Author: lymslive / 2016-08-27

" public function entrance
function! microcmd#EV#Commander(...) "{{{
    " when no argument, edit vimrc
    if a:0 == 0 || len(a:1) == 0
        edit $MYVIMRC
        return 1
    endif

    let l:arg = a:1

    " edit the current ftplugin
    if l:arg == '.'
        let l:filetype = &filetype
        let l:path = $VIMHOME . '/ftplugin/' . l:filetype . '.vim'
        execute 'edit ' . l:path
        return 1
    endif

    " edit the current snip file of filetype
    if l:arg == ',' && exists(':UltiSnipsEdit')
        UltiSnipsEdit
        return 1
    endif

    " eidt [b:]bufnr or [s:]SID, numbered argument
    if l:arg =~? '^[sb]\?:\?\d\+'
        return s:find_number(l:arg)
    endif

    " provide full path 
    if filereadable(l:arg)
        execute 'edit ' . l:arg
        return 1
    endif

    " try to edit #sharp#function, mainly copied from message
    " the last #part should function name
    if l:arg =~# '#'
        return debug#lookup#GotoSharpFunc(l:arg)
    endif

    " search in runtime path
    let l:path = s:FindinRTP(l:arg)
    if len(l:path) > 0
        execute 'edit ' . l:path
        return 1
    endif

    echo 'cannot find vim file: ' . l:arg
    return 0
endfunction "}}}

" Func: s:find_number 
function! s:find_number(arg) abort "{{{
    let l:number = matchstr(a:arg, '\zs\d\+\ze$')
    if empty(l:number)
        return
    endif

    let l:type = a:arg[0]
    if l:type ==? 'b' || l:type !=? 's' && bufexists(l:number)
        execute 'buffer' l:number
        return
    else
        let l:Scripts = package#imports('package', 'scripts')
        let l:lsVimfile = l:Scripts()
        let l:pFilePath = l:lsVimfile[l:number-1]
        execute 'edit' l:pFilePath
        return 1
    endif
endfunction "}}}

" try to find a file in runtime path or it's plugin subdirectory
" the argument `file` may with or without `.vim` extension
function! s:FindinRTP(file) "{{{
    let l:rtps = split(&runtimepath, ',')
    for l:rtp in l:rtps
        let l:path = l:rtp . '/' . a:file
        if filereadable(l:path)
            return l:path
        endif
        let l:path = l:rtp . '/' . a:file . '.vim'
        if filereadable(l:path)
            return l:path
        endif
        let l:path = l:rtp . '/plugin/' . a:file
        if filereadable(l:path)
            return l:path
        endif
        let l:path = l:rtp . '/plugin/' . a:file . '.vim'
        if filereadable(l:path)
            return l:path
        endif
    endfor
    return ''
endfunction "}}}

" custom completion
function! microcmd#EV#Complist(ArgLead, CmdLine, CursorPos) "{{{
    " from empty, complete rumtimepath
    if empty(a:ArgLead)
        return split(globpath(&runtimepath, a:ArgLead), "\n")
    endif

    " add wildchar
    let l:ArgLead = a:ArgLead . '*'

    " already provide path
    if l:ArgLead =~ '/'
		let l:globstr = glob(l:ArgLead)
		if !empty(l:globstr)
			return split(l:globstr, "\n")
		endif
    endif

    " glob in currnet and runtime paths 
    let l:paths = getcwd() . ',' . &runtimepath
    return split(globpath(l:paths, l:ArgLead), "\n")
endfunction "}}}
" NOTE:
" this method will insert full path before ArgLead,
" so use -complete=customlist other than -complete=custom
