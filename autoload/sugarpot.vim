scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:sfile = expand("<sfile>")
let s:is_windows = has('win16') || has('win32') || has('win64')

function! s:make_xpm(image)
	let name = fnamemodify(a:image, ":t:r")
	let output_dir = g:sugarpot_xpm_cache_directory."/".name
	let output = output_dir."/".name.".xpm"
	if !isdirectory(output_dir)
		call mkdir(output_dir, "p")
	endif
	if filereadable(output)
		call delete(output)
	endif
	try
		let resize = empty(g:sugarpot_convert_resize) ? "" : ("-resize ".g:sugarpot_convert_resize)
		let result = system(g:sugarpot_convert." ".resize." ".g:sugarpot_convert_cmd_option." ".a:image. " " . output)
	catch /.*/
		echo v:exception
	endtry
	return output
endfunction


function! s:write(data)
	let i = 0
	for line in a:data
		call setline(i, line)
		let i += 1
	endfor
endfunction


function! s:remove_pixels_header(xpm)
	return a:xpm[index(a:xpm, '/* pixels */') : len(a:xpm)-2]
endfunction

function! s:make_buffer()
	enew
	syntax on
	setlocal laststatus=0
	setlocal guioptions=
	setlocal showtabline=0
	setlocal cmdwinheight=1
	setlocal buftype=nowrite
	setlocal noswapfile
	setlocal bufhidden=wipe
	setlocal nonumber
	setlocal nowrap
	setlocal nocursorline
	setlocal nocursorcolumn
	setlocal conceallevel=2
	setlocal concealcursor=n
	highlight clear Visual
	highlight clear Cursor
	let &guifont = g:sugarpot_font
endfunction


function! s:render(xpm)
	let xpm = a:xpm
	let image = s:remove_pixels_header(xpm)
	let width  = len(get(image, 2))
	let height = len(image)

	call s:write(xpm)
	set ft=xpm
	syntax match XPM_INV /,/ transparent conceal
	syntax match XPM_INV2 /"/ transparent conceal
	silent %d _
	call s:write(image)
	normal! gg
	let &columns = width+2
	let &lines   = height
	redraw
endfunction


function! s:is_url(str)
	return a:str =~# 'http.*'
endfunction

function! s:download(url)
	let output_dir = g:sugarpot_xpm_cache_directory."/".fnamemodify(a:url, ":t:r")
	let output = output_dir."/".fnamemodify(a:url, ":t")
	if !isdirectory(output_dir)
		call mkdir(output_dir, "p")
	endif
	if !executable(g:sugarpot_curl)
		echoerr "Please install ".g:sugarpot_curl
		return ""
	endif
	call system("curl -o ".output." ".a:url)
	return output
endfunction


function! s:image_main(file)
	augroup sugarpot-delay
		autocmd!
	augroup END
	
	if s:is_url(a:file)
		retur s:image_main(s:download(a:file))
	endif

	if !executable(g:sugarpot_convert)
		echoerr "Please install convert"
		return
	endif
	if !filereadable(a:file)
		echoerr "Not found ".a:file
		return
	endif
	if !isdirectory(g:sugarpot_xpm_cache_directory)
		echoerr "Invalid g:sugarpot_xpm_cache_directory : " . g:sugarpot_xpm_cache_directory
		return
	endif
	let image_filename = a:file
	let xpm_filename = s:make_xpm(image_filename)
	if !filereadable(xpm_filename)
		echoerr "Can't read ".xpm_filename
		return
	endif

	call s:make_buffer()
	call s:render(readfile(xpm_filename))
endfunction


function! sugarpot#render_image(filename)
	augroup sugarpot-delay
		autocmd!
		silent execute "autocmd CursorHold * call s:image_main(".string(a:filename).")"
	augroup END
endfunction


function! s:send_value(server, vname)
	call sugarpot#remote#remote_execute(a:server, "let ".a:vname."=".string(eval(a:vname)))
endfunction

function! s:open_preview(server, filename)
	let filename   = fnamemodify(a:filename, ":p")
	let plugin_dir = fnamemodify(s:sfile, ":p:h:h")
	let plugin     = plugin_dir."/plugin/sugarpot.vim"
	let server = sugarpot#remote#start(a:server, g:sugarpot_gvim_cmd_option)
	call sugarpot#remote#wait_start(server)
	call remote_foreground(server)
	call sugarpot#remote#remote_execute(server, "set updatetime=10")
	call sugarpot#remote#remote_execute(server, "set runtimepath+=".plugin_dir)
	call sugarpot#remote#remote_execute(server, "source ".plugin)
	if s:is_windows
		call sugarpot#remote#remote_execute(server, 'set shell=C:\\WINDOWS\\system32\\cmd.exe')
	endif
	call s:send_value(server, "g:sugarpot_convert_resize")
	call s:send_value(server, "g:sugarpot_font")
	call s:send_value(server, "g:sugarpot_xpm_cache_directory")
	call s:send_value(server, "g:sugarpot_gvim")
	call s:send_value(server, "g:sugarpot_gvim_cmd_option")
	call s:send_value(server, "g:sugarpot_curl")
	call s:send_value(server, "g:sugarpot_convert")
	call s:send_value(server, "g:sugarpot_convert_resize")
	call s:send_value(server, "g:sugarpot_convert_cmd_option")
	call sugarpot#remote#remote_execute(server, "SugarpotRenderImage ".filename."<CR>")
	call foreground()
endfunction


function! sugarpot#open_preview(filename, ...)
	let server = get(a:, 1, "")
	let server = empty(server) ? fnamemodify(a:filename, ":t:r") : server
	return s:open_preview(server, a:filename)
endfunction


function! sugarpot#close_preview(...)
	let server = get(a:, 1, g:sugarpot_default_servername)
	call sugarpot#remote#quit(server)
endfunction

function! sugarpot#close_preview_all()
	call sugarpot#remote#quit_all()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

