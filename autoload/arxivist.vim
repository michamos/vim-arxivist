let s:arxiv2md = expand('<sfile>:p:h') . '/../arxiv2md.py'

function! arxivist#open_entry(date,...)
  let today = strftime("%F")
  let bang = a:0 && a:1 ? '!' : ''
  if empty(a:date)
    let date = today
  elseif a:date =~# '^/' "date is actually a pattern
    call arxivist#search( substitute(a:date, '^/', '', '') )
    return
  else
    let date = a:date
  endif
  let file = expand(g:arxivist_dir) . date . ".md"
  if filereadable(file)
    execute "edit" . bang file
  elseif date == today
    execute 'edit' . bang  '+call\ arxivist#new_entry(today)' file
  else
    echohl ErrorMsg
    echomsg "Arxivist: No entry for" date
    echohl None
  endif
endfunction

function! arxivist#open_next_entry(direction, ...)
  let current_date = expand("%:r")
  call arxivist#open_entry( arxivist#get_next_date(current_date, a:direction), a:0 && a:1 ? a:1 : '')
endfunction

function! arxivist#new_entry(today)
  let header_text = "% Journal entry for " . a:today
  execute "normal! i". header_text . "\n\n"
  echon "Fetch the "  g:arxivist_archive  " new listing? (Y/n)"
  let answer = nr2char(getchar())
  if answer =~? "\[y\<CR>\<Space>\]"
    echo "Fetching the arXiv..."
    silent execute "read!" . s:arxiv2md  g:arxivist_archive
    if v:shell_error
      3normal! o**There was an error while retrieving the arXiv, please fix it and try again.**
      normal! o
      normal! oThis file will **not** be saved!
      normal! o
      normal! o---
      normal! o
      normal! o*Error log:*
      normal! o
      execute "normal! j\<C-V>GI> \<Esc>"
      setlocal buftype=nowrite bufhidden=delete noswapfile
    endif
    redraw
  endif
endfunction

function! arxivist#list_existing_dates()
  let old_pwd = getcwd()
  execute 'lcd' g:arxivist_dir
  let markdown_files = glob('*.md')
  execute 'lcd' old_pwd
  "drop '.md' extension
  return split(substitute(markdown_files, '\.md\(\n\|$\)', '\1', 'g'), '\n')
endfunction

function! arxivist#get_next_date(date, ...)
  let direction = a:0 > 0 && a:1 < 0 ? -1 : 1
  let dates = arxivist#list_existing_dates()
  return get(dates, index(dates, a:date)+direction, strftime("%F"))
endfunction

function! arxivist#complete_command(A,L,P)
  return join( reverse( copy(arxivist#list_existing_dates()) ), "\n")
endfunction

function! arxivist#search(pattern)
  if exists(':Ag') == 2
    let search_command = 'Ag'
  elseif exists(':Ack') ==2
    let search_command = 'Ack'
  else
    "Need some flags to act more like ag
    let search_command = 'grep -E -r'
  endif
  let pattern = "'" . substitute(a:pattern, '\s\+', '\\s+', 'g') . "'"
  execute search_command pattern g:arxivist_dir
endfunction

function! arxivist#open_current_link()
  let last_search=@/
  let pos = getpos(".")
  if search('##', "cbW") == 0
    "there is no previous subsection
    return
  endif
  call search('\[Link](.', "ceW")
  normal gx
  let @/=last_search
  call setpos(".",pos)
endfunction

function! arxivist#init_buffer()
  let b:arxivist_entry = 1
  map <buffer><silent> <CR> :call arxivist#open_current_link()<CR>
  command! -bang -buffer Narxivist call arxivist#open_next_entry(1, <bang>0)
  command! -bang -buffer Parxivist call arxivist#open_next_entry(-1, <bang>0)
  if strftime("%F") != expand("%:r") "Not opening today's file
    set nomodifiable readonly
  endif
endfunction
