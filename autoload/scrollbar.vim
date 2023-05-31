let s:sb_block = ''

function! scrollbar#Setup() abort
      if g:scrollbar_enabled
            call scrollbar#Show()

            augroup scrollbar_show_hide
                  autocmd!
                  autocmd WinEnter * call scrollbar#Show()
                  autocmd WinLeave * call scrollbar#Hide()
            augroup END
      endif

      call scrollbar#signs#Setup()
endfunction

function! scrollbar#Disable() abort
      call scrollbar#signs#Disable()
      call scrollbar#cursor#Disable()

      let g:scrollbar_enabled = 0
      call scrollbar#Hide()
      silent! augroup! scrollbar_show_hide
endfunction

function! scrollbar#Enable() abort
      let g:scrollbar_enabled = 1
      call scrollbar#Setup()
endfunction

function! s:Update() abort
      call scrollbar#Hide()

      let dims = scrollbar#helpers#GetDimensions()
      let lines = scrollbar#helpers#GetLines()

      if scrollbar#helpers#CanShowScrollbar(lines.total, dims.win_height)
            return
      endif

      let b:scrollbar_height = scrollbar#helpers#CalcScrollbarCoord(dims.win_height, lines.total)
      let b:scrollbar_start = dims.win_top + min([scrollbar#helpers#CalcScrollbarCoord(line('w0'), lines.total) - 1, dims.win_height - b:scrollbar_height + 1]) - 1
      let b:scrollbar_col = dims.win_left + dims.win_width

      let b:scrollbar_popup_id = popup_create(repeat([s:sb_block], b:scrollbar_height), { 
                        \ 'line': b:scrollbar_start,
                        \ 'col': b:scrollbar_col,
                        \ 'minwidth': 1,
                        \ 'maxwidth': 1,
                        \ 'maxheight': dims.win_height,
                        \ 'highlight': 'ScrollbarBlock',
                        \ 'zindex': 1
                        \ })
      call popup_show(b:scrollbar_popup_id)
endfunction

function! scrollbar#Show() abort
      if !g:scrollbar_enabled
            return
      endif

      try
            call s:Update()
            call scrollbar#signs#Update({})
      catch
            echohl ErrorMsg
            echomsg "Oops! Scrollbar failed with " . v:exception . " at: " . v:throwpoint
            echohl None
      endtry
endfunction

function! scrollbar#Hide() abort
      if exists('b:scrollbar_popup_id')
            call popup_close(b:scrollbar_popup_id)
      endif
endfunction
