if !exists('g:sign_notify_plugin_list')
	let g:sign_notify_plugin_list = []
endif

function! s:DoesSignExist(mySign)
	let a:ret = 1
	try
		silent execute 'sign list ' . a:mySign . ' buffer=' . bufnr('%')
	catch
		let a:ret = 0
	endtry

	return a:ret
endfunction

function! s:SetDummySign()
	if !s:DoesSignExist('dummySign')
		sign define dummySign
		silent execute 'sign place 9999 line=1 name=dummySign buffer=' . bufnr('%')
	endif
endfunction

function! s:UnSetDummySign()
	if s:DoesSignExist('dummySign')
		silent execute 'sign unplace 9999 buffer=' . bufnr('%')
		sign undefine dummySign
	endif
endfunction

function! s:ResetTopSign(lineNumber)
endfunction

function! s:ResetBottomSign(lineNumber)
endfunction

function! s:GetSignList()
	" list all signs in current buffer
	redir => a:cmd
	silent execute 'sign place buffer=' . bufnr('%')
	redir END

	" split the string
	let a:list = split(b:cmd, ' ')

	let a:signs = []
	for i in a:list
		if !empty(matchstr(i, 'line=*'))
			let a:signs = add(b:signs, str2nr(strpart(i, 5, len(i))))
		endif
	endfor

	return a:signs[1:]
endfunction

function! s:SignNotify()
	let a:flag = 1
	for i in g:sign_notify_plugin_list
		if exists(i)
			let a:flag = 0

			" set dummy sign
			call s:SetDummySign()

			" get the line number of signs
			let a:signs = s:GetSignList()
			let a:windoTop = line('w0') 
			let a:windoBottom = line('w$')
			let a:beforeTop = 0
			let a:afterBottom = 0
		
			for i in a:signs
				if (i < a:windoTop)
					let a:beforeTop = 1
				endif
				if (i > a:windoBottom)
					let a:afterBottom = 1
				endif
			endfor

			break
		endif
	endfor

	if a:flag
		call s:UnSetDummySign()
		call s:ResetTopSign(0)
		call s:ResetBottomSign(0)
	endif
endfunction

augroup signnotify
	autocmd!
	autocmd CursorMoved,CursorMovedI * call s:SignNotify()
	autocmd BufWritePost,FileWritePost * call s:SignNotify()
augroup END
