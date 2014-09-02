if exists("g:loaded_arxivist") || &cp || v:version < 700
  finish
endif
let g:loaded_arxivist = 1

command! -nargs=? -complete=custom,arxivist#complete_command Arxivist call arxivist#open_entry(<q-args>)

