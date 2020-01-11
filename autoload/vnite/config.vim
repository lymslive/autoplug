" File: config
" Author: lymslive
" Description: vnite config for vnite
" Create: 2019-10-31
" Modify: 2019-10-31

" short cute to prefix current cmdline
cnoremap <C-J>   <Home>CM -- <CR>
cnoremap <C-CR>  <Home>CM -- <CR>
nnoremap <S-CR>  :CM<CR>
nnoremap <C-CR>  :CM Vnite<CR>
nnoremap <C-CR>1 :CM 1<CR>
nnoremap <C-CR>2 :CM 2<CR>
nnoremap <C-CR>3 :CM 3<CR>
nnoremap <C-CR>4 :CM 4<CR>
nnoremap <C-CR>5 :CM 5<CR>
nnoremap <C-CR>6 :CM 6<CR>
nnoremap <C-CR>7 :CM 7<CR>
nnoremap <C-CR>8 :CM 8<CR>
nnoremap <C-CR>9 :CM 9<CR>
nnoremap <C-CR>b :CM ls<CR>
nnoremap <C-CR>o :CM oldfiles<CR>
nnoremap <C-CR>s :CM scriptnames<CR>
nnoremap <C-CR>r :CM registers<CR>
nnoremap <C-CR>m :CM marks<CR>
nnoremap <C-CR>j :CM jumps<CR>
nnoremap <C-CR>f :CM File<CR>
nnoremap <C-CR>F :CM -- File -r<CR>

" maps in message buffer where command output
function! vnite#config#buffer_maps() abort
    nnoremap <buffer> q :q<CR>
    nnoremap <buffer> / :StartFilter<CR>
    nnoremap <buffer> <CR> :call vnite#action#run('CR')<CR>
    nnoremap <buffer> <Tab> :call vnite#action#more()<CR>
    nnoremap <buffer> ? :call vnite#action#more()<CR>

    command! -buffer -bang -nargs=? Action :call vnite#action#run(<q-args>, <bang>0)
endfunction

" global filter mode maps
function! vnite#config#filter_maps() abort
    Fnoremap <Tab> <Esc>:call vnite#action#more()<CR>
    Fnoremap <CR>  <Esc>:call vnite#filter#lineCR()<CR>
    Fnoremap <C-P> <Esc>:call vnite#filter#lineup()<CR>
    Fnoremap <C-N> <Esc>:call vnite#filter#linedown()<CR>
    Fnoremap <C-J> <Esc>:call vnite#filter#line2end()<CR>
    Fnoremap <C-L> <C-U><Esc>
endfunction

" some command behave or act on output similarly 
let g:vnite#config#sharecmd = {
            \ 'scriptnames' : 'oldfiles',
            \ 'buffers' : 'ls',
            \ 'files' : 'ls'
            \ }

" to add list by :Vnite command
let g:vnite#config#extracmdlist = [
            \ 'scriptnames |" list all sourced script, CR to open one'
            \ ]

" the height of message window
let g:vnite#config#winheight = 15
" the short promt string in the filter cmdline
let g:vnite#config#prompt_filter = 'Filter>> '
" the history amount to keep the recent used CM command
let g:vnite#config#hotcmds = 10

let g:vnite#config#project_marker = ['.git', '.svn', '.vim']
let g:vnite#config#project_filelist = ['project.files', 'GFILES']

" configs that can be override by individual command
" when open CM message buffer, start filter mode automaticlly
let g:vnite#config#start_filter = 0
" reserve filter text when reopen message window
let g:vnite#config#reserve_filter = 0
" when first to new message, scroll to the end bottom
let g:vnite#config#start_toend = 0
" after press <CR> to fire action, keep CM buffer open
let g:vnite#config#keep_open = 0

function! vnite#config#load() abort "{{{
    return 1
endfunction "}}}
