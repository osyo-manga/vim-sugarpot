scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! sugarpot#remote#remote_execute(server, command)
	return remote_send(a:server, ":".a:command."<CR>")
endfunction


let s:remote_list = []
function! sugarpot#remote#start(server, ...)
	if sugarpot#remote#is_started(a:server)
		return a:server
	endif
	let option = get(a:, 1, "")
	silent execute '!start '.g:sugarpot_gvim.' --servername '.a:server.' '.option.''
	call add(s:remote_list, a:server)
	return a:server
endfunction


function! sugarpot#remote#list()
	return deepcopy(filter(s:remote_list, "sugarpot#remote#is_started(v:val)"))
endfunction


function! sugarpot#remote#quit(server)
	if sugarpot#remote#is_started(a:server)
		return sugarpot#remote#remote_execute(a:server, "qall!")
	endif
endfunction


function! sugarpot#remote#quit_all()
	call map(sugarpot#remote#list(), "sugarpot#remote#quit(v:val)")
endfunction


function! sugarpot#remote#is_started(server)
	try
		return remote_expr(a:server, "1")
	catch /.*/
		return 0
	endtry
endfunction

function! sugarpot#remote#wait_start(server)
	while !sugarpot#remote#is_started(a:server) | endwhile
endfunction


function! sugarpot#remote#wait_quit(server)
	while sugarpot#remote#is_started(a:server) | endwhile
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

