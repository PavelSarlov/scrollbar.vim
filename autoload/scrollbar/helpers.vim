function! scrollbar#helpers#CalcScrollbarCoord(coord, total_lines) abort
      let dims = scrollbar#helpers#GetDimensions()
      return dims.win_top + min([max([float2nr(ceil(1.0 * a:coord / a:total_lines * dims.win_height)), 1]), dims.win_height]) - 1
endfunction

function! scrollbar#helpers#IsInsideScrollbar(line) abort
      return a:line >= b:scrollbar_start && a:line <= b:scrollbar_start + b:scrollbar_height
endfunction

function! scrollbar#helpers#GetLines()
      let total = line('$')
      let current = line('.')
      let folds = s:GetClosedFolds()

      for fold in folds
            let total = total - fold.lines 
            if fold.start < current
                  let current = current - fold.lines
            endif
      endfor

      return { 'total': total, 'current': current }
endfunction

function! scrollbar#helpers#GetDimensions() abort
      let [win_top, win_left] = win_screenpos(0)
      let [win_width, win_height] = [winwidth(0), winheight(0)]
      let cur_line = line('.')
      return {
                        \ 'win_top': win_top,
                        \ 'win_left': win_left,
                        \ 'win_width': win_width,
                        \ 'win_height': win_height,
                        \ 'cur_line': cur_line
                        \ }
endfunction

function! scrollbar#helpers#CanShowScrollbar(lines, win_height) abort
      return a:lines <= a:win_height + 1
endfunction

function! s:GetClosedFolds() abort
      if mode() !=# 'n'
            return []
      endif

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

function! scrollbar#helpers#DefineHl() abort
      hi def ScrollbarError   ctermfg=DarkRed    guifg=DarkRed    guibg=NONE ctermbg=NONE
      hi def ScrollbarWarning ctermfg=DarkYellow guifg=DarkYellow guibg=NONE ctermbg=NONE
      hi def ScrollbarHint    ctermfg=Yellow     guifg=Yellow     guibg=NONE ctermbg=NONE
      hi def ScrollbarInfo    ctermfg=White      guifg=white      guibg=NONE ctermbg=NONE

      execute "hi def ScrollbarBlock        ctermfg=" . g:scrollbar_cursor_term_color  . " guifg=" . g:scrollbar_cursor_gui_color . " guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
      execute "hi def ScrollbarCursorBlock  ctermfg=" . g:scrollbar_cursor_term_color  . " guifg=" . g:scrollbar_cursor_gui_color . " guibg=NONE                          ctermbg=NONE"
      execute "hi def ScrollbarErrorBlock   ctermfg=DarkRed                                guifg=DarkRed                              guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
      execute "hi def ScrollbarWarningBlock ctermfg=DarkYellow                             guifg=DarkYellow                           guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
      execute "hi def ScrollbarHintBlock    ctermfg=Yellow                                 guifg=Yellow                               guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
      execute "hi def ScrollbarInfoBlock    ctermfg=White                                  guifg=White                                guibg=" . g:scrollbar_gui_color . " ctermbg=" . g:scrollbar_term_color
endfunction
