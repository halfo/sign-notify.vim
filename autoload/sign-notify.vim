if !exists('g:sign_notify_plugin_list')
	let g:sign_notify_plugin_list = []
endif

function! s:IsDummySignExists()
	let s:ret = 1
	try
		redir => b:cmd
		silent execute 'sign list dummySign buffer=' . bufnr('%')
		redir END
	catch
		let s:ret = 0
	endtry

	return s:ret
endfunction

function! s:SetDummy()
	if !s:IsDummySignExists()
		sign define dummySign
		silent execute 'sign place 9999 line=1 name=dummySign buffer=' . bufnr('%')
	endif
endfunction

function! s:UnSetDummy()
	if s:IsDummySignExists()
		silent execute 'sign unplace 9999 buffer=' . bufnr('%')
		sign undefine dummySign
	endif
endfunction

function! s:GetList()
	" list all signs in current buffer
	redir => b:cmd
	silent execute 'sign place buffer=' . bufnr('%')
	redir END

	" split the string
	let b:list = split(b:cmd, ' ')

	" find tokens that are 'line=%d' format
	let b:regex = 'line=*'
	let b:signs = []
	for i in b:list
		if !empty(matchstr(i, b:regex))
			let b:length = len(i)
			let b:signs = add(b:signs, str2nr(strpart(i, 5, b:length)))
		endif
	endfor

	return b:signs[1:]
endfunction

function! s:SignNotify()
	let b:flag = 1
	for i in g:sign_notify_plugin_list
		if exists(i)
			let b:flag = 0

			" set dummy sign
			call s:SetDummy()

			" get the line number of signs
			let b:signs = s:GetList()
			let b:top = line('w0')
			let b:bottom = line('w$')
			let b:topFlag = 0
			let b:topBottom = 0
		
			for i in b:signs
				if (i < b:top)
					let topFlag = 1
				endif
				if (i > b:bottom)
					let topBottom = 1
				endif
			endfor

			break
		endif
	endfor

	if b:flag
		call s:UnSetDummy()
	endif
endfunction

augroup signnotify
	autocmd!
	autocmd CursorMoved,CursorMovedI * call s:SignNotify()
	autocmd BufWritePost,FileWritePost * call s:SignNotify()
augroup END
