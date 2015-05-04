function! s:SignNotify()
	if !exists('#goyo')
		return
	endif

	redir => b:cmd
	silent execute 'sign place buffer=' . bufnr('%')
	redir END

	let b:list = split(b:cmd, ' ')

	let b:regex = 'line=*'
	let b:signs = []
	for i in b:list
		if !empty(matchstr(i, b:regex))
			let b:length = len(i)
			let b:signs = add(b:signs, str2nr(strpart(i, 5, b:length)))
		endif
	endfor

	echo b:signs[1:]
	" return b:signs[1:]
endfunction

augroup signnotify
	autocmd!
	autocmd CursorMovedI * call s:SignNotify()
	autocmd CursorMoved * call s:SignNotify()
augroup END
