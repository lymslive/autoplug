" File: coding#plugin
" Author: lymslive
" Description: for common coding
" Create: 2018-05-05
" Modify: 2018-05-05
"

PI edvsplit usetabpg microcmd qcmotion wraptext

packadd nerdtree
packadd tagbar

packadd ultisnips
packadd vim-snippets

packadd vimproc.vim
packadd unite.vim
packadd neoyank.vim
" packadd neomru.vim
" packadd unite-outline
" packadd unite-help
" packadd neoinclude.vim
" packadd unite-tag
" packadd vim-unite-cscope

packadd neocomplete.vim
" packadd YouCompleteMe
packadd clang_complete

packadd ack.vim
" packadd vim-dict
packadd incsearch.vim

packadd vim-surround
" packadd vim-signature

" NERDTree: {{{1
nnoremap \f :NERDTreeToggle<CR>
nnoremap \F :NERDTreeMirror<CR>
" 自动关闭
let NERDTreeQuitOnOpen=1

" Tagbar: {{{1
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
nnoremap \t :Tagbar<CR>

" Unite: {{{1
call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap \u :Unite 
nnoremap <C-p><CR> :Unite<CR>
nnoremap <C-p><Space> :Unite 
nnoremap <C-n> :<C-u>UniteResume<CR>
nnoremap <C-p>f :<C-u>Unite -buffer-name=files file<CR>
nnoremap <C-p>b :<C-u>Unite -buffer-name=buffer buffer bookmark<CR>
nnoremap <C-p>m :<C-u>Unite -buffer-name=mur file_mru<CR>
nnoremap <C-p>t :<C-u>Unite -buffer-name=tag tag<CR>
nnoremap <C-p>o :<C-u>Unite -buffer-name=outline outline<CR>
nnoremap <C-p>r :<C-u>Unite register<CR>
nnoremap <C-p>y :<C-u>Unite -buffer-name=yank history/yank<CR>
nnoremap <C-p>j :<C-u>Unite jump<CR>

" unite grep source
if executable('ag')
    " Use ag (the silver searcher)
    " https://github.com/ggreer/the_silver_searcher
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts =
                \ '-i --vimgrep --hidden --ignore ' .
                \ '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
    let g:unite_source_grep_recursive_opt = ''
elseif executable('ack')
    " Use ack
    " http://beyondgrep.com/
    let g:unite_source_grep_command = 'ack'
    let g:unite_source_grep_default_opts =
                \ '-i --no-heading --no-color -k -H'
    let g:unite_source_grep_recursive_opt = ''
endif

" grep by prompt
nnoremap <C-p>g :<C-u>Unite -buffer-name=grep grep<CR>
" grep current word in current dir
nnoremap <C-p><C-g> :<C-u>Unite -buffer-name=grep -input=<C-R><C-W> grep:.<CR>

" Neocomplete: {{{1
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#auto_completion_start_length = 3
let g:neocomplete#ignore_source_files = ['tag.vim']
let g:neocomplete#enable_ignore_case = 1
" let g:neocomplete#enable_smart_case = 1
let g:neocomplete#text_mode_filetypes = 
            \ {'text':1, 'markdown':1, 'tex':1, 'help':1} 
let g:neocomplete#sources#dictionary#dictionaries = 
            \ {'default':'', 'text':'~/.vim/dict/english.dic'}
command! NE NeoCompleteEnable

" Neosnippet: {{{1
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
let g:neosnippet#snippets_directory = '~/.vim/bundle/neosnippet-snippets/neosnippets'

" OmniCppComplete: {{{1 
set completeopt=noselect,menu
nnoremap <F6> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" Signature: {{{1
nnoremap \m :SignatureToggleSigns<CR>

" Cscope: {{{1
" see: cscope_maps.vim bt Jason Duell
if has("cscope")

    " use relative path of cscpo.out
    set cscoperelative

    " use :cstag instead of the defualt :tag
    set cscopetag

    " search tas files, after cscope database
    set cscopetagorder=0

    " print message
    set cscopeverbose

    " use quickfix for some cs find command
    set cscopequickfix=s-,c-,d-,i-,t-,e-

    " automatic load cscope.out
    if filereadable("cscope.out")
        cs add cscope.out  
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif

    " common map manage cscope work
    nnoremap <C-\>a :cs add cscope.out<CR>
    nnoremap <C-\>r :!cscope -Rbq<CR>
    nnoremap <C-\>h :cs help<CR>
    nnoremap <C-\>\ :cs find f 

    " find things under cursor
    nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
    nnoremap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nnoremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>	

    " horizontally split find
    nnoremap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>	
    nnoremap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nnoremap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>	
    nnoremap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>	

    " vertical split find
    nnoremap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>	
    nnoremap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>	
    nnoremap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
endif

" YouCompleteMe: {{{1
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
let g:ycm_collect_identifiers_from_tags_files=1
let g:ycm_min_num_of_chars_for_completion=3
let g:ycm_seed_identifiers_with_syntax=1

" Ultisnips: {{{1
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsEnableSnipMate = 0
let g:snips_author = 'lymslive'

" Clang_complete: {{{1
let g:clang_snippets=1
let g:clang_snippets_engine="ultisnips"
let g:clang_use_library=1
let g:clang_close_preview=1
let g:clang_complete_macros=1
let g:clang_user_options='-stdlib=libc++ -std=c++11 -ICPLUS_INCLUDE_PATH'

" 不冲突 C-] C-T 快捷键
let g:clang_jumpto_declaration_key = '<C-\><C-]>'
let g:clang_jumpto_declaration_in_preview_key = '<C-\><C-p>'
let g:clang_jumpto_back_key = '<C-\><C-T>'

" Incsearch Map: {{{1
" 增量搜索优化
nmap /  <Plug>(incsearch-forward)
nmap ?  <Plug>(incsearch-backward)
nmap g/ <Plug>(incsearch-stay)

" LOAD:
function! coding#plugin#load(...) abort "{{{
    return 1
endfunction "}}}

