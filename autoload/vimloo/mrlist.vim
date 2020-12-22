" most recent list: fixed size array
" can only add new item at tial 
" the vaild array content is [head, tail)
" head and tail will wrap around when to end
" full if head == tail again
let s:class = {}
let s:class.capacity = 0
let s:class.array = []
let s:class.head = 0
let s:class.tail = 0

function! vimloo#mrlist#new(capacity)
    let l:obj = deepcopy(s:class)
    let l:obj.capacity = a:capacity
    let l:obj.array = repeat([''], a:this.capacity)
    let l:obj.head = -1
    let l:obj.tail = -1
    return l:obj
endfunction

" Size: 
function! s:class.Size() dict abort "{{{
    if self.head < 0
        return 0
    endif

    if self.tail > self.head
        return self.tail - self.head
    else
        return self.tail - self.head + self.capacity
    endif
endfunction "}}}

" MaxSize: 
function! s:class.MaxSize() dict abort "{{{
    return self.capacity
endfunction "}}}

" IsFull: 
function! s:class.IsFull() dict abort "{{{
    return self.head >= 0 && self.head == self.tail
endfunction "}}}

" IsEmpty: 
function! s:class.IsEmpty() dict abort "{{{
    return self.head < 0 && self.tail < 0
endfunction "}}}

" Clear: 
function! s:class.Clear() dict abort "{{{
    call map(self.array, '""')
    let self.head = -1
    let self.tail = -1
    return self
endfunction "}}}

" Add: add a item to tail, or rearrange to tail if already existed
function! s:class.Add(item) dict abort "{{{
    " first item
    if self.IsEmpty()
        let self.array[0] = a:item
        let self.head = 0
        let self.tail = 1
        return self
    endif

    " already in the tail
    if a:item == self.array[self.tail-1]
        return self
    endif

    let l:size = self.Size()
    let l:scan = 0
    let l:bFound = v:false

    " re-add old item?
    let l:idx = self.head
    while l:scan < l:size
        if l:idx >= self.capacity
            let l:idx = 0
        endif

        let l:item = self.array[l:idx]
        if l:item == a:item && !l:bFound
            let l:bFound = v:true
        elseif l:bFound
            let self.array[l:idx-1] = self.array[l:idx]
        endif

        let l:idx += 1
        let l:scan += 1
    endwhile

    if l:bFound
        let self.array[l:idx-1] = a:item
        return self
    endif

    " add new item
    let self.array[self.tail] = a:item
    let self.tail += 1
    if self.tail >= self.capacity
        let self.tail = 0
    endif

    " full array
    if l:size == self.capacity
        let self.head = self.tail
    endif

    return self
endfunction "}}}

" Normalize: return a normalized list
function! s:class.Normalize() dict abort "{{{
    if self.IsEmpty()
        return []
    endif

    if self.tail > self.head
        return self.array[self.head : self.tail - 1]
    endif

    let l:list = self.array[self.head : ]
    if self.tail > 0
        call extend(l:list, self.array[0 : self.tail - 1])
    endif

    return l:list
endfunction "}}}
" list: 
function! s:class.list() dict abort "{{{
    return self.Normalize()
endfunction "}}}

" Resize: 
function! s:class.Resize(capacity) dict abort "{{{
    if self.capacity == a:capacity
        return self
    endif

    let l:list = self.Normalize()
    let l:size = self.Size()

    if self.capacity < a:capacity
        call extend(l:list, repeat([''], a:capacity - self.capacity))
        let self.array = l:list
    else
        let self.array = l:list[0 : a:capacity - 1]
    endif

    let self.head = 0
    let self.tail = l:size

    return self
endfunction "}}}

" Reserve: 
function! s:class.Reserve(capacity) dict abort "{{{
    if self.capacity < a:capacity
        return self.Resize(a:capacity)
    endif

    return self
endfunction "}}}

" Fill: fill the queue, option a:1 is bIgnoreEmpty
function! s:class.Fill(array, ...) dict abort "{{{
    if self.IsFull() || empty(a:array)
        return self
    endif

    if type(a:array) != type([])
        :ELOG 'requeue.fill expect a list'
        return self
    endif

    let l:bIgnoreEmpty = get(a:000, 0, v:false)

    let l:left = self.MaxSize() - self.Size()

    if self.head < 0
        let self.head = 0
    endif
    if self.tail < 0
        let self.tail = 0
    endif

    let l:count = 0
    for l:item in a:array
        if l:count >= l:left
            break
        endif

        if empty(l:item) && l:bIgnoreEmpty
            continue
        endif

        let self.array[self.tail] = l:item
        let self.tail += 1
        if self.tail >= self.capacity
            let self.tail = 0
        endif
        let l:count += 1
    endfor

    return self
endfunction "}}}
