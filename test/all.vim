
function! s:owl_begin()
	let g:owl_success_message_format = "%f:%l:[Success] %e"
endfunction

function! s:owl_end()
	let g:owl_success_message_format = ""
endfunction


let s:current_dir = expand("<sfile>:p:h")


function! s:test_all()
	let test_files = split(globpath(s:current_dir, "*/*"), "\n")
	for file in test_files
		execute "source" file
		call owl#run(file)
	endfor
endfunction
" call G_owl_run(expand("<sfile>"))

