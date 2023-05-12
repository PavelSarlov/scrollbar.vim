function! scrollbar#Calculate() abort
      let [win_top, win_left] = win_screenpos(0)
      let [win_width, win_height] = [winwidth(0), winheight(0)]
      let lines = line('$')
      let cur_line = line('.')

      if lines <= win_height
            return [[], {}]
      endif

      let scrollbar_scale = 1.0 * win_height / lines
      let scrollbar_height = max([float2nr(ceil(scrollbar_scale * win_height)), 1])

      let scroll_pos_coef = 1.0 * line('w0') / lines
      let line_pos = win_top + min([max([float2nr(ceil(scroll_pos_coef * win_height)), 1]), win_height - scrollbar_height + 1]) - 1
      let col_pos = win_left + win_width - 1

      let bar = repeat('▐', scrollbar_height)

      return [bar, { 
                        \ 'line': line_pos,
                        \ 'col': col_pos,
                        \ 'minwidth': 1,
                        \ 'maxwidth': 1,
                        \ 'maxheight': win_height,
                        \ }]
endfunction

function! scrollbar#Show() abort
      if !g:scrollbar_enabled
            return
      endif

      call scrollbar#Hide()

      try
            let [bar, options] = scrollbar#Calculate()
            let b:scrollbar_popup_id = popup_create(bar, options)
            call popup_show(b:scrollbar_popup_id)
      catch
            echomsg "Oops! Scrollbar failed with " . v:exception
      endtry
endfunction

function! scrollbar#Hide() abort
      if exists('b:scrollbar_popup_id')
            call popup_close(b:scrollbar_popup_id)
      endif
endfunction

function! scrollbar#Setup() abort
      if g:scrollbar_enabled
            call scrollbar#Show()

            augroup scrollbar_show_hide
                  autocmd!
                  autocmd WinEnter * call scrollbar#Show()
                  autocmd WinLeave * call scrollbar#Hide()
            augroup END
      endif
endfunction

function! scrollbar#Disable() abort
      let g:scrollbar_enabled = 0
      call scrollbar#Hide()
      silent augroup! scrollbar_show_hide
endfunction

function! scrollbar#Enable() abort
      let g:scrollbar_enabled = 1
      call scrollbar#Setup()
endfunction

