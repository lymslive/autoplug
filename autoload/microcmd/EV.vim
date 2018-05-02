" EV.vim
"   implement (functions) of this plugin
" Author: lymslive / 2016-08-27

" public function entrance
function! microcmd#EV#Commander(...) "{{{1
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

    " provide full path 
    if filereadable(l:arg)
        execute 'edit ' . l:arg
        return 1
    endif

    " try to edit #sharp#function, mainly copied from message
    " the last #part should function name
    if l:arg =~# '#'
        return edit#vim#GotoSharpFunc(l:arg)
    endif

    " search in runtime path
    let l:path = s:FindinRTP(l:arg)
    if len(l:path) > 0
        execute 'edit ' . l:path
        return 1
    endif

    echo 'cannot find vim file: ' . l:arg
    return 0
endfunction

" try to find a file in runtime path or it's plugin subdirectory
" the argument `file` may with or without `.vim` extension
function! s:FindinRTP(file) "{{{1
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
endfunction

" custom completion
function! microcmd#EV#Complist(ArgLead, CmdLine, CursorPos) "{{{1
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
endfunction
" NOTE:
" this method will insert full path before ArgLead,
" so use -complete=customlist other than -complete=custom
