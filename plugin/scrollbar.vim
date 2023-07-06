if exists('g:scrollbar_loaded') || &cp
  finish
endif

let g:scrollbar_loaded = '0.0.1'
let s:keepcpo = &cpo
set cpo&vim

if !exists("g:scrollbar_enabled")
  let g:scrollbar_enabled = 0
endif

if !exists('g:scrollbar_signs_enabled')
  let g:scrollbar_signs_enabled = g:scrollbar_enabled
endif

if !exists('g:scrollbar_cursor_enabled')
  let g:scrollbar_cursor_enabled = g:scrollbar_enabled
endif

if !exists('g:scrollbar_term_color')
  let g:scrollbar_term_color = "DarkBlue"
endif
if !exists('g:scrollbar_cursor_term_color')
  let g:scrollbar_cursor_term_color = "White"
endif
if !exists('g:scrollbar_gui_color')
  let g:scrollbar_gui_color = "#494d64"
endif
if !exists('g:scrollbar_cursor_gui_color')
  let g:scrollbar_cursor_gui_color = "#FFFFFF"
endif

call scrollbar#helpers#DefineHl()

function DisableAll() abort
  call scrollbar#Disable()
  call scrollbar#signs#Disable()
  call scrollbar#cursor#Disable()
endfunction

function EnableAll() abort
  call scrollbar#Enable()
  call scrollbar#signs#Enable()
  call scrollbar#cursor#Enable()
endfunction

command! ScrollbarEnable call scrollbar#Enable()
command! ScrollbarDisable call scrollbar#Disable()
command! ScrollbarSignsEnable call scrollbar#signs#Enable()
command! ScrollbarSignsDisable call scrollbar#signs#Disable()
command! ScrollbarCursorEnable call scrollbar#cursor#Enable()
command! ScrollbarCursorDisable call scrollbar#cursor#Disable()
command! ScrollbarDisableAll call DisableAll()
command! ScrollbarEnableAll call EnableAll()

function EmitLinesChanged() abort
  if !exists('b:current_lines')
    let b:current_lines = line('$')
  endif
  if b:current_lines != line('$')
    let b:current_lines = line('$')
    doautocmd User LinesChanged
  endif
endfunction

function EmitCursorMovedVertically() abort
  if !exists('b:current_cursor_pos')
    let b:current_cursor_pos = line('.')
  endif
  if b:current_cursor_pos != line('.')
    let b:current_cursor_pos = line('.')
    doautocmd User CursorMovedVertically
  endif
endfunction

augroup lines_changed
  autocmd!
  autocmd TextChanged,TextChangedI,TextChangedP * call EmitLinesChanged()
augroup END

augroup cursor_moved_vertically
  autocmd!
  autocmd CursorMoved,CursorMovedI * call EmitCursorMovedVertically()
augroup END

augroup scrollbar_setup
  autocmd!
  autocmd WinEnter,FocusGained,WinScrolled,VimResized,VimEnter * call scrollbar#Setup()
  autocmd User LinesChanged call scrollbar#Setup()
augroup END

augroup scrollbar_signs_setup
  autocmd!
  autocmd WinEnter,VimEnter * call scrollbar#signs#Setup()
augroup END

augroup scrollbar_cursor_setup
  autocmd!
  autocmd WinEnter,FocusGained,WinScrolled,VimResized,VimEnter * call scrollbar#cursor#Setup()
  autocmd User CursorMovedVertically call scrollbar#cursor#Setup()
augroup END

let &cpo = s:keepcpo
unlet s:keepcpo
