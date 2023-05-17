let s:sb_block = ' '

let s:sb_signs_priority = ['Error', 'Warning', 'Hint', 'Info']
let s:sb_signs = ['-', '=', '≡']


highlight ScrollbarBlock guibg=Grey ctermbg=Grey ctermfg=NONE guifg=NONE 

highlight ScrollbarError ctermfg=Red guifg=Red
highlight ScrollbarWarning ctermfg=DarkYellow guifg=DarkYellow
highlight ScrollbarHint ctermfg=Yellow guifg=Yellow
highlight ScrollbarInfo ctermfg=White guifg=white

highlight ScrollbarErrorBlock ctermfg=Red guifg=Red guibg=Grey ctermbg=Grey
highlight ScrollbarWarningBlock ctermfg=DarkYellow guifg=DarkYellow guibg=Grey ctermbg=Grey
highlight ScrollbarHintBlock ctermfg=Yellow guifg=Yellow guibg=Grey ctermbg=Grey
highlight ScrollbarInfoBlock ctermfg=White guifg=White guibg=Grey ctermbg=Grey

function! s:GetDimensions() abort
      let [win_top, win_left] = win_screenpos(0)
      let lines = line('$')

      let folds = scrollbar#GetClosedFolds()

      for fold in folds
            let lines = lines - fold.lines 
      endfor

      return {
                        \ 'win_top': win_top,
                        \ 'win_left': win_left,
                        \ 'win_width': winwidth(0),
                        \ 'win_height': winheight(0),
                        \ 'cur_line': line('.'),
                        \ 'lines': lines
                        \ }
endfunction

function! s:CalcScrollbarCoord(coord, lines, win_height) abort
      return min([max([float2nr(ceil(1.0 * a:coord / a:lines * a:win_height)), 1]), a:win_height])
endfunction

function! scrollbar#UpdateScrollbar() abort
      let dims = s:GetDimensions()
      let signs = scrollbar#GetSigns()

      if dims.lines <= dims.win_height
            return
      endif

      let scrollbar_height = s:CalcScrollbarCoord(dims.win_height, dims.lines, dims.win_height)
      let bar = repeat(s:sb_block, scrollbar_height)

      let scrollbar_start = min([s:CalcScrollbarCoord(line('w0'), dims.lines, dims.win_height) + 1, dims.win_height - scrollbar_height + 1])
      let scrollbar_col = dims.win_left + dims.win_width

      let b:scrollbar_popup_id = popup_create(bar, { 
                        \ 'line': scrollbar_start,
                        \ 'col': scrollbar_col,
                        \ 'minwidth': 1,
                        \ 'maxwidth': 1,
                        \ 'maxheight': dims.win_height,
                        \ 'highlight': 'ScrollbarBlock',
                        \ 'zindex': 1
                        \ })
      call popup_show(b:scrollbar_popup_id)

      let b:scrollbar_sign_popup_ids = []
      for sign in signs
            let sign_line = s:CalcScrollbarCoord(sign.line, dims.lines, dims.win_height)

            let is_in_bar = sign_line >= scrollbar_start && sign_line <= scrollbar_start + scrollbar_height

            let sign_popup_id = popup_create('-', { 
                              \ 'line': sign_line,
                              \ 'col': scrollbar_col,
                              \ 'minwidth': 1,
                              \ 'maxwidth': 1,
                              \ 'highlight': 'Scrollbar' . s:sb_signs_priority[sign.priority] . (is_in_bar ? 'Block' : ''),
                              \ 'zindex': 2
                              \ })
            call popup_show(sign_popup_id)
            call add(b:scrollbar_sign_popup_ids, sign_popup_id)
      endfor
endfunction

function! scrollbar#UpdateSigns() abort
endfunction

function! scrollbar#Show() abort
      if !g:scrollbar_enabled
            return
      endif

      try
            call scrollbar#Hide()
            call scrollbar#UpdateScrollbar()
            call scrollbar#UpdateSigns()
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
      if exists('b:scrollbar_sign_popup_ids')
            for id in b:scrollbar_sign_popup_ids
                  call popup_close(id)
            endfor
            let b:scrollbar_sign_popup_ids = []
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

function! scrollbar#GetSigns() abort
      let signs = flatten(map(sign_getplaced(bufnr(), {'group': '*'}), {_, val -> val.signs}))
      return map(signs, { _, val -> 
                        \ { 
                        \ 'line': val.lnum,
                        \ 'priority': scrollbar#GetSignPriority(val.name) 
                        \ }
                        \ })
endfunction

function! scrollbar#GetSignPriority(name) abort
      for index in range(len(s:sb_signs_priority))
            if (a:name =~ '.*' . s:sb_signs_priority[index] . '.*') 
                  return index
            endif
      endfor
endfunction
