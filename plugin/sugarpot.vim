if exists('g:loaded_sugarpot')
  finish
endif
let g:loaded_sugarpot = 1

let s:save_cpo = &cpo
set cpo&vim


let g:sugarpot_default_servername  = get(g:, "g:sugarpot_default_servername", "sugarpot_image_preview_server")
let g:sugarpot_font                = get(g:, "sugarpot_font", &guifont.":h1")
let g:sugarpot_xpm_cache_directory = get(g:, "sugarpot_xpm_cache_directory", $TEMP)

let g:sugarpot_gvim            = get(g:, "sugarpot_gvim", "gvim")
let g:sugarpot_gvim_cmd_option = get(g:, "sugarpot_gvim_cmd_option", "-n -u NONE -U NONE -i NONE")

let g:sugarpot_convert            = get(g:, "sugarpot_convert", "convert")
let g:sugarpot_convert_resize     = get(g:, "sugarpot_convert_resize", "50%")
let g:sugarpot_convert_cmd_option = get(g:, "sugarpot_convert_cmd_option", "convert")

let g:sugarpot_convert_cmd_option = get(g:, "sugarpot_convert_cmd_option", "convert")

let g:sugarpot_curl = get(g:, "sugarpot_curl", "curl")

let g:sugarpot_remote_start_cmd = get(g:, "sugarpot_remote_start_cmd", "start")


command! -nargs=1 -complete=file
\	SugarpotRenderImage
\	call sugarpot#render_image(<q-args>)


command! -bang -nargs=1 -complete=file
\	SugarpotPreview
\	call sugarpot#open_preview(<q-args>, <bang>!1 ? g:sugarpot_default_servername : "")


function! s:complete_server(argload, ...)
	return filter(sugarpot#remote#list(), "v:val =~? '".a:argload."'")
endfunction

command! -nargs=* -complete=customlist,s:complete_server
\	SugarpotClosePreview
\	call sugarpot#close_preview(<q-args>)

command! -nargs=*
\	SugarpotClosePreviewAll
\	call sugarpot#close_preview_all()


augroup sugarpot-augroup
	autocmd!
	autocmd VimLeave * SugarpotClosePreviewAll
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
