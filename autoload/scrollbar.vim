let s:sb_block = ' '

let s:sb_signs_priority = {
                  \ 'Error': 1,
                  \ 'Warning': 2,
                  \ 'Hint': 3,
                  \ 'Info': 4
                  \ }

let s:sb_signs = {
                  \ 1: '-',
                  \ 2: '=',
                  \ 3: '≡'
                  \ }

highlight ScrollbarBlock guibg=Grey ctermbg=Grey ctermfg=NONE guifg=NONE 
highlight ScrollbarError ctermfg=Red guifg=Red
highlight ScrollbarWarning ctermfg=DarkYellow guifg=DarkYellow
highlight ScrollbarHint ctermfg=Yellow guifg=Yellow
highlight ScrollbarInfo ctermfg=White guifg=white

function! scrollbar#CalculateBar() abort
      let [win_top, win_left] = win_screenpos(0)
      let [win_width, win_height] = [winwidth(0), winheight(0)]
      let lines = line('$')
      let cur_line = line('.')
      let folds = scrollbar#GetClosedFolds()
      let signs = scrollbar#GetSigns()

      echomsg signs

      for fold in folds
            let lines = lines - fold.lines 
      endfor

      if lines <= win_height
            return
      endif

      let scrollbar_scale = 1.0 * win_height / lines
      let scrollbar_height = max([float2nr(ceil(scrollbar_scale * win_height)), 1])
      let bar = repeat(s:sb_block, scrollbar_height)

      let scroll_pos_coef = 1.0 * line('w0') / lines
      let scrollbar_start = win_top + min([max([float2nr(ceil(scroll_pos_coef * win_height)), 1]), win_height - scrollbar_height + 1]) - 1
      let scrollbar_col = win_left + win_width


      let b:scrollbar_popup_id = popup_create(bar, { 
                        \ 'line': scrollbar_start,
                        \ 'col': scrollbar_col,
                        \ 'minwidth': 1,
                        \ 'maxwidth': 1,
                        \ 'maxheight': win_height,
                        \ 'highlight': 'ScrollbarBlock'
                        \ })
      call popup_show(b:scrollbar_popup_id)

      "       let b:scrollbar_sign_popup_ids = []
      "       for sign in signs
      "             let id = popup_create(bar, { 
      "                               \ 'line': scrollbar_start,
      "                               \ 'col': scrollbar_col,
      "                               \ 'minwidth': 1,
      "                               \ 'maxwidth': 1,
      "                               \ 'maxheight': win_height,
      "                               \ 'highlight': 'ScrollbarBlock'
      "                               \ })
      "             call popup_show(id)
      "             call add(b:scrollbar_sign_popup_ids, id)
      "       endfor
endfunction

function! scrollbar#CalculateSigns() abort
      let signs = scrollbar#GetSigns()
      echomsg signs
endfunction

function! scrollbar#Show() abort
      if !g:scrollbar_enabled
            return
      endif

      try
            call scrollbar#Hide()
            call scrollbar#CalculateBar()
      catch
            echohl ErrorMsg
            echomsg "Oops! Scrollbar failed with " . v:exception . " at: "
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
      for [key, value] in items(s:sb_signs_priority)
            if (a:name =~ '.*' . key . '.*') 
                  return value
            endif
      endfor
endfunction

function! scrollbar#GetKeyByValue(dict, value) abort
      for [k, v] in items(a:dict)
            if v == a:value
                  return k
            endif
      endfor
      return v:null
endfunction
