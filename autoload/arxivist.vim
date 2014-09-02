let s:arxiv2md = expand('<sfile>:p:h') . '/../arxiv2md.py'

function! arxivist#open_entry(date)
  let today = strftime("%F")
  if empty(a:date)
    let date = today
  elseif a:date ==? "yesterday"
    let date = strftime("%F", localtime()-86400)
  elseif a:date =~# '^/' "date is actually a pattern
    call arxivist#search( substitute(a:date, '^/', '', '') )
    return
  else
    let date = a:date
  endif
  let file = expand(g:arxivist_dir) . date . ".md"
  if date == today
    if filereadable(file)
      execute "edit " . file
    else
      execute 'edit +call\ arxivist#new_entry(today) ' . file
    endif
  else
    if filereadable(file)
      execute 'view +set\ nomodifiable' file
    else
      echohl ErrorMsg
      echomsg "Arxivist: No entry for" date
      echohl None
    endif
  endif
endfunction

function! arxivist#new_entry(today)
  let header_text = "% Journal entry for " . a:today
  execute "normal! i". header_text . "\n\n"
  echon "Fetch the "  g:arxivist_archive  " new listing? (Y/n)"
  let answer = nr2char(getchar())
  if answer =~? "\[y\<CR>\]"
    echo "Fetching the arXiv..."
    silent execute "read!" . s:arxiv2md  g:arxivist_archive
    redraw
  endif
endfunction

function! arxivist#complete_command(A,L,P)
  let old_pwd = getcwd()
  execute 'lcd' g:arxivist_dir
  let markdown_files = glob('*.md')
  execute 'lcd' old_pwd
  "drop '.md' extension
  return substitute(markdown_files, '\.md\(\n\|$\)', '\1', 'g')
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
