
" function! s:test_execute()
" 	call sugarpot#remote#execute("OwlCheck 1")
" 
" 	call sugarpot#remote#execute("let g:sugarpot_test = 42")
" 	OwlCheck g:sugarpot_test == 42
" 
" 	call sugarpot#remote#execute("unlet g:sugarpot_test")
" 	OwlCheck !has_key(g:, "sugarpot_test")
" endfunction

function! s:start(server)
	return sugarpot#remote#start(a:server, " -u NONE -U NONE")
endfunction

function! s:test_wait()
	let server = sugarpot#remote#start("42", " -u NONE -U NONE")
	call sugarpot#remote#wait_start(server)
	OwlCheck sugarpot#remote#is_started(server)

	call sugarpot#remote#quit(server)
	call sugarpot#remote#wait_quit(server)
	OwlCheck !sugarpot#remote#is_started(server)
endfunction

function! s:test_start()
	let server = sugarpot#remote#start("mami", " -u NONE -U NONE")
	call sugarpot#remote#wait_start(server)
	OwlCheck remote_expr(server, "1 + 1") == 2
	call sugarpot#remote#quit(server)
	call sugarpot#remote#wait_quit(server)
endfunction


function! s:test_list()
	let server1 = s:start("homu")
	call sugarpot#remote#wait_start(server1)
	let server2 = s:start("mami")
	call sugarpot#remote#wait_start(server2)

	OwlCheck sugarpot#remote#list() == [server1, server2]

	call sugarpot#remote#quit(server2)
	call sugarpot#remote#wait_quit(server2)
	OwlCheck sugarpot#remote#list() == [server1]

	call sugarpot#remote#quit_all()
endfunction

