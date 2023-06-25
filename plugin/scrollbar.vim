if exists('g:scrollbar_loaded') || &cp
  finish
endif

let g:scrollbar_loaded = '0.0.1'
let s:keepcpo = &cpo
set cpo&vim

if !exists("g:scrollbar_enabled")
  let g:scrollbar_enabled = 0
endif

if exists('g:scrollbar_signs_enabled')
  let g:scrollbar_signs_enabled = g:scrollbar_enabled ? g:scrollbar_signs_enabled : 0
else
  let g:scrollbar_signs_enabled = g:scrollbar_enabled
endif

if exists('g:scrollbar_cursor_enabled')
  let g:scrollbar_cursor_enabled = g:scrollbar_enabled ? g:scrollbar_cursor_enabled : 0
else
  let g:scrollbar_cursor_enabled = g:scrollbar_enabled
endif

if !exists('g:scrollbar_term_color')
  let g:scrollbar_term_color = "DarkBlue"
endif
if !exists('g:scrollbar_cursor_term_color')
  let g:scrollbar_cursor_term_color = "White"
endif
if !exists('g:scrollbar_gui_color')
  let g:scrollbar_gui_color = "#8AADF4"
endif
if !exists('g:scrollbar_cursor_gui_color')
  let g:scrollbar_cursor_gui_color = "#000000"
endif

call scrollbar#DefineHl()

command! ScrollbarEnable call scrollbar#Enable()
command! ScrollbarDisable call scrollbar#Disable()

augroup scrollbar_setup
  autocmd!
  autocmd QuitPre,WinEnter,FocusGained,WinScrolled,VimResized,VimEnter,TextChanged,TextChangedI,TextChangedP * call scrollbar#Setup()
augroup END

augroup scrollbar_cursor_setup
  autocmd!
  autocmd QuitPre,WinEnter,FocusGained,WinScrolled,VimResized,VimEnter,TextChanged,TextChangedI,TextChangedP,CursorMoved,CursorMovedI * call scrollbar#cursor#Setup()
augroup END

let &cpo = s:keepcpo
unlet s:keepcpo
