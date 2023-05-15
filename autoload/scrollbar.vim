function! scrollbar#Calculate() abort
      let [win_top, win_left] = win_screenpos(0)
      let [win_width, win_height] = [winwidth(0), winheight(0)]
      let lines = line('$')
      let cur_line = line('.')
      let folds = scrollbar#GetClosedFolds()

      for fold in folds
           let lines = lines - fold.lines 
      endfor

      if lines <= win_height
            return [[], {}]
      endif

      let scrollbar_scale = 1.0 * win_height / lines
      let scrollbar_height = max([float2nr(ceil(scrollbar_scale * win_height)), 1])

      let scroll_pos_coef = 1.0 * line('w0') / lines
      let line_pos = win_top + min([max([float2nr(ceil(scroll_pos_coef * win_height)), 1]), win_height - scrollbar_height + 1]) - 1
      let col_pos = win_left + win_width

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

function! scrollbar#GetClosedFolds() abort
      let view = winsaveview()
      let keepj = 'keepj norm!'
      exe keepj 'gg'
      let folds = []
      let cur_line = line('.')
      while 1
            if foldclosed(cur_line)
                  let fold_end = foldclosedend(cur_line)
                  call add(folds, { 'start': cur_line, 'end': fold_end, 'lines': fold_end - cur_line })
            endif
            exe keepj 'zj'
            if line('.') == cur_line
                  break
            endif
            let cur_line = line('.')
      endwhile
      call winrestview(view)
      call filter(folds, {idx, val -> val.end > 0})
      return folds
endfunction
