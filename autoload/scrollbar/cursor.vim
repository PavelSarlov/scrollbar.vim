let s:sb_cursor = '*'

function! scrollbar#cursor#Setup() abort
      if g:scrollbar_cursor_enabled && exists('b:scrollbar_height')
            call scrollbar#cursor#Show()

            augroup scrollbar_cursor_show_hide
                  autocmd!
                  autocmd BufEnter,WinEnter * call scrollbar#cursor#Show()
                  autocmd BufLeave,WinLeave * call scrollbar#cursor#Hide()
            augroup END
      endif

      call scrollbar#signs#Setup()
endfunction

function! scrollbar#cursor#Disable() abort
      let g:scrollbar_cursor_enabled = 0
      call scrollbar#cursor#Hide()
      silent! augroup! scrollbar_cursor_show_hide
endfunction

function! scrollbar#cursor#Enable() abort
      let g:scrollbar_cursor_enabled = 1
      call scrollbar#cursor#Setup()
endfunction

function! scrollbar#cursor#Show() abort
      if !g:scrollbar_cursor_enabled
            return
      endif

      try
            call s:Update()
      catch
            echohl ErrorMsg
            echomsg "Oops! Scrollbar cursor failed with " . v:exception . " at: " . v:throwpoint
            echohl None
      endtry
endfunction

function! scrollbar#cursor#Hide() abort
      if exists('b:scrollbar_cursor_popup_id')
            call popup_close(b:scrollbar_cursor_popup_id)
      endif
endfunction

function! s:Update() abort
      call scrollbar#cursor#Hide()

      if !exists('b:scrollbar_col')
            return
      endif

      let dims = scrollbar#helpers#GetDimensions()
      let lines = scrollbar#helpers#GetLines()

      if scrollbar#helpers#CanShowScrollbar(lines.total, dims.win_height)
            return
      endif

      let line = scrollbar#helpers#CalcScrollbarCoord(lines.current, lines.total)

      let b:scrollbar_cursor_popup_id = popup_create([s:sb_cursor], { 
                        \ 'line': line,
                        \ 'col': b:scrollbar_col,
                        \ 'minwidth': 1,
                        \ 'maxwidth': 1,
                        \ 'highlight': 'ScrollbarBlock',
                        \ 'zindex': 2
                        \ })
      call popup_show(b:scrollbar_cursor_popup_id)
endfunction
