if !exists("g:scrollbar_enabled")
  let g:scrollbar_enabled = 0
endif

command! ScrollbarEnable call scrollbar#Enable()
command! ScrollbarDisable call scrollbar#Disable()

augroup scrollbar
  autocmd!
  autocmd VimEnter,CursorMoved,CursorMovedI,TextChanged,TextChangedI,TextChangedP * call scrollbar#Setup()
augroup END
