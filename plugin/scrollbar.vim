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

if !exists('g:scrollbar_color')
  let g:scrollbar_color = "DarkBlue"
endif
if !exists('g:scrollbar_cursor_color')
  let g:scrollbar_cursor_color = "White"
endif

hi ScrollbarError        ctermfg=DarkRed    guifg=DarkRed    guibg=NONE      ctermbg=NONE
hi ScrollbarWarning      ctermfg=DarkYellow guifg=DarkYellow guibg=NONE      ctermbg=NONE
hi ScrollbarHint         ctermfg=Yellow     guifg=Yellow     guibg=NONE      ctermbg=NONE
hi ScrollbarInfo         ctermfg=White      guifg=white      guibg=NONE      ctermbg=NONE

execute "hi ScrollbarBlock        ctermfg=" . g:scrollbar_cursor_color  . " guifg=" . g:scrollbar_cursor_color . " guibg=" . g:scrollbar_color . " ctermbg=" . g:scrollbar_color
execute "hi ScrollbarErrorBlock   ctermfg=DarkRed                           guifg=DarkRed                          guibg=" . g:scrollbar_color . " ctermbg=" . g:scrollbar_color
execute "hi ScrollbarWarningBlock ctermfg=DarkYellow                        guifg=DarkYellow                       guibg=" . g:scrollbar_color . " ctermbg=" . g:scrollbar_color
execute "hi ScrollbarHintBlock    ctermfg=Yellow                            guifg=Yellow                           guibg=" . g:scrollbar_color . " ctermbg=" . g:scrollbar_color
execute "hi ScrollbarInfoBlock    ctermfg=White                             guifg=White                            guibg=" . g:scrollbar_color . " ctermbg=" . g:scrollbar_color

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
