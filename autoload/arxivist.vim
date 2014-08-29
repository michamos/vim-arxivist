let s:arxiv2md = expand('<sfile>:p:h') . '/../arxiv2md.py'

function! arxivist#open_entry(date)
  let today = strftime("%F")
  if empty(a:date)
    let date = today
  elseif a:date =~ "yesterday"
    let date = strftime("%F", localtime()-86400)
  else
    let date = string(a:date)
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
  if answer =~ "\[yY\<CR>\]"
    silent execute "read!" . s:arxiv2md  g:arxivist_archive
  endif
endfunction

