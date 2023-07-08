let s:sb_signs_priority = ['Error', 'Warning', 'Hint', 'Info']
let s:sb_signs = ['-', '=']

function! scrollbar#signs#Setup() abort
      if g:scrollbar_signs_enabled && exists('b:scrollbar_height') 
            call scrollbar#signs#Show({})

            augroup scrollbar_signs_show_hide
                  autocmd!
                  autocmd BufLeave,WinLeave * call scrollbar#signs#Hide()
            augroup END
      endif
endfunction

function! scrollbar#signs#Disable() abort
      let g:scrollbar_signs_enabled = 0
      call scrollbar#signs#Hide()
      silent! augroup! scrollbar_signs_show_hide
endfunction

function! scrollbar#signs#Enable() abort
      let g:scrollbar_signs_enabled = 1
      call scrollbar#signs#Setup()
endfunction

function! scrollbar#signs#Show(timer) abort
      if !g:scrollbar_signs_enabled
            return
      endif

      try
            call scrollbar#signs#Update()
            let b:signs_update_timer = timer_start(1000, function('scrollbar#signs#Show'), { 'repeat': -1 })
      catch
            echohl ErrorMsg
            echomsg "Oops! Scrollbar signs failed with " . v:exception . " at: " . v:throwpoint
            echohl None
      endtry
endfunction

function! scrollbar#signs#Update() abort
      call scrollbar#signs#Hide()

      if !exists('b:scrollbar_col')
            return
      endif

      let dims = scrollbar#helpers#GetDimensions()
      let lines = scrollbar#helpers#GetLines()

      if scrollbar#helpers#CanShowScrollbar(lines.total, dims.win_height)
            return
      endif

      let signs = s:GetSigns()

      let signs_per_line = {}
      for sign in signs
            if has_key(signs_per_line, sign.line)
                  call add(signs_per_line[sign.line], sign.priority)
            else
                  let signs_per_line[sign.line] = [sign.priority]
            endif
      endfor

      let b:sign_popup_ids = []
      for [line, signs] in items(signs_per_line)
            let sign_line = scrollbar#helpers#CalcScrollbarCoord(line, lines.total)
            let sorted_signs = sort(signs)

            let sign_popup_id = popup_create(s:sb_signs[len(signs) > 1], { 
                              \ 'line': sign_line,
                              \ 'col': b:scrollbar_col,
                              \ 'minwidth': 1,
                              \ 'maxwidth': 1,
                              \ 'highlight': 'Scrollbar' . s:sb_signs_priority[sorted_signs[0]] . (scrollbar#helpers#IsInsideScrollbar(sign_line) ? 'Block' : '') ,
                              \ 'zindex': 3
                              \ })
            call popup_show(sign_popup_id)
            call add(b:sign_popup_ids, sign_popup_id)
      endfor
endfunction

function! scrollbar#signs#Hide() abort
      if exists('b:signs_update_timer')
            call timer_stop(b:signs_update_timer)
      endif
      if exists('b:sign_popup_ids')
            for id in b:sign_popup_ids
                  call popup_close(id)
            endfor
            let b:sign_popup_ids = []
      endif
endfunction

function! s:GetSigns() abort
      let signs = flatten(map(sign_getplaced(bufnr(), {'group': '*'}), {_, val -> val.signs}))
      return map(signs, { _, val -> 
                        \ { 
                        \ 'line': val.lnum,
                        \ 'priority': s:GetSignPriority(val.name) 
                        \ }
                        \ })
endfunction

function! s:GetSignPriority(name) abort
      for index in range(len(s:sb_signs_priority))
            if (a:name =~ '.*' . s:sb_signs_priority[index] . '.*') 
                  return index
            endif
      endfor
endfunction
