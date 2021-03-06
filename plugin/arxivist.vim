if exists("g:loaded_arxivist") || &cp || v:version < 700
  finish
endif
let g:loaded_arxivist = 1

command! -bang -nargs=? -complete=custom,arxivist#complete_command Arxivist call arxivist#open_entry(<q-args>, <bang>0)

augroup arxivist
  autocmd!
  execute "autocmd BufEnter" g:arxivist_dir . '*.md call arxivist#init_buffer()'
  execute "autocmd BufLeave" g:arxivist_dir . '*.md set modifiable noreadonly'
augroup END
