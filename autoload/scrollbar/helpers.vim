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
            echomsg fold
            let total = total - fold.lines 
            if fold.start < current
                  let current = current - fold.lines
            endif
      endfor

      return { 'total': total, 'current': current }
endfunction

function! scrollbar#helpers#GetDimensions() abort
      let [win_top, win_left] = win_screenpos(0)
      return {
                        \ 'win_top': win_top,
                        \ 'win_left': win_left,
                        \ 'win_width': winwidth(0),
                        \ 'win_height': winheight(0),
                        \ 'win_line': winline(),
                        \ 'cur_line': line('.'),
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
