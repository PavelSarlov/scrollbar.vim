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

hi def ScrollbarError   ctermfg=DarkRed    guifg=DarkRed    guibg=NONE ctermbg=NONE
hi def ScrollbarWarning ctermfg=DarkYellow guifg=DarkYellow guibg=NONE ctermbg=NONE
hi def ScrollbarHint    ctermfg=Yellow     guifg=Yellow     guibg=NONE ctermbg=NONE
hi def ScrollbarInfo    ctermfg=White      guifg=white      guibg=NONE ctermbg=NONE

execute "hi def ScrollbarBlock        ctermfg=" . g:scrollbar_cursor_term_color  . " guifg=" . g:scrollbar_cursor_gui_color . " guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
execute "hi def ScrollbarErrorBlock   ctermfg=DarkRed                           guifg=DarkRed                          guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
execute "hi def ScrollbarWarningBlock ctermfg=DarkYellow                        guifg=DarkYellow                       guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
execute "hi def ScrollbarHintBlock    ctermfg=Yellow                            guifg=Yellow                           guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
execute "hi def ScrollbarInfoBlock    ctermfg=White                             guifg=White                            guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color

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
