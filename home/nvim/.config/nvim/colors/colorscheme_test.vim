hi clear

if exists("syntax_on")
	syntax reset
endif

let colors_name="colorscheme_test"

function! Cterm2gui(n)
	if type(a:n) == 1
		return a:n
	elseif a:n < 7
		let rgb = [128 * (a:n % 2), 128 * ((a:n/2) % 2), 128 * ((a:n/4) % 2)]
	elseif a:n == 7
		let rgb = [192, 192, 192]
	elseif a:n == 8
		let rgb = [128, 128, 128]
	elseif a:n < 16
		let rgb = [256 * (a:n % 2), 256 * ((a:n/2) % 2), 256 * ((a:n/4) % 2)]
	elseif a:n < 232
		let values = [0, 95, 135, 175, 215, 255]
		let rgb = [values[((a:n-16)/36) % 6], values[((a:n-16)/6) % 6], values[(a:n-16) % 6]]
	else
		let val = (a:n-232)*10 + 8
		let rgb = [val, val, val]
	endif
	return printf("#%02x%02x%02x", rgb[0], rgb[1], rgb[2])
endfunction

let g:gui_cols = []
let k = 0
while k < 256
	let g:gui_cols += [Cterm2gui(k)]
	let k += 1
endwhile

function! Gui2cterm(v)
	if a:v == "NONE"
		return a:v
	endif
	let k = 0
	while k < 256
		if g:gui_cols[k] == a:v
			return k
		end
		let k += 1
	endwhile
	return 0
endfunction

function! SetColorDefault(cterm_col, names)
	for name in a:names
		exec printf('hi %s ctermbg=bg ctermfg=%d cterm=NONE guibg=bg guifg=%s gui=NONE', name, a:cterm_col, Cterm2gui(a:cterm_col))
	endfor
endfunction

function! SetColor(cterm_col, cterm_bg, style, names)
	for name in a:names
		exec printf('hi %s ctermbg=%d ctermfg=%d cterm=%s guibg=%s guifg=%s gui=%s', name, a:cterm_bg, a:cterm_col, a:style, Cterm2gui(a:cterm_bg), Cterm2gui(a:cterm_col), a:style)
	endfor
endfunction

if &t_Co >= 256 || has("gui_running")

	call SetColor("#ffffd7", "#000000", "NONE", ["Normal", "signColumn","Question", "signColumn", "Question", "Constant", "helpLeadBlank", "helpNormal", "VisualNOS", "PmenuSbar", "PMenuThumb", "CtrlPPrtText", "VimFunction", "Directory"])
	set background=dark
	"call SetColorDefault("#5fafd7", ["Number","SpecialKey","Boolean","CtrlPBufferNr"])
	call SetColorDefault("#5f87d7", ["Number","SpecialKey","Boolean","CtrlPBufferNr"])
	call SetColorDefault("#5fd75f", ["Type"])
	call SetColorDefault("#870000", ["CtrlPNoEntries", "javaScriptFunctionKey", "DiffDelete"])
	call SetColorDefault("#d75f00", ["CtrlPPtrCursor", "Statement"])
	call SetColorDefault("#ffaf5f", ["manLongOptionDesc", "CtrlPBufferVis", "PreProc", "Special", "javaScriptObjectKey"])
	call SetColorDefault("#875f5f", ["markdownLinkDelimiter", "Ignore", "qfLineNr", "Folded", "CtrlPLinePre", "CtrlPPrtBase", "TabLine", "markdownUrl"])
	call SetColorDefault("#af8787", ["Comment", "LineNr"])
	call SetColorDefault("#d7af87", ["markdownCodeBlock", "markdownCode", "String"])
	call SetColorDefault("#ffd7af", ["CursorLineNr", "CtrlPBufferInd"])
	call SetColorDefault("#ffd787", ["Function"])
	call SetColorDefault("#ffd75f", ["Operator", "WildMenu","TabLineSel","ModeMsg","MoreMsg","WarningMsg","manOptionDesc","CtrlPMatch"])
	call SetColorDefault("#a8a8a8", ["Identifier"])
	call SetColorDefault("#6c6c6c", ["NonText", "StatusLine", "Delimeter", "VimIsCommand", "htmlItalic", "markdownLinkTextDelimiter", "StatusLineNC", "VertSplit", "FoldColumn", "ColorColumn"])

	call SetColor("#ffffd7", "#870000", "NONE", ["ErrorMsg", "Error"])
	call SetColor("#000000", "#d75f00", "NONE", ["Cursor", "IncSearch"])
	call SetColor("#000000", "#ffaf5f", "NONE", ["Visual"])
	call SetColor("#000000", "#d7af87", "NONE", ["Search"])

	call SetColor("#ffffd7", "#262626", "NONE", ["DiffAdd", "VimMapLhs", "TabLineFill"])
	call SetColor("#d7875f", "#262626", "NONE", ["DiffText"])
	call SetColor("#d7af87", "#262626", "NONE", ["VimSubstRep4"])
	call SetColor("#ffd75f", "#262626", "NONE", ["PmenuSel", "Underlined"])
	call SetColor("#a8a8a8", "#262626", "NONE", ["Pmenu", "DiffChange"])

	call SetColor("#870000", "NONE", "NONE", ["SpellBad", "SpellLocal"])
	call SetColor("#d7af87", "NONE", "NONE", ["SpellRare"])
	call SetColor("#ffd75f", "NONE", "NONE", ["SpellCap"])

	call SetColor("#ffffd7", "#000000", "bold", ["Title", "Todo"])
	call SetColor("#ffd75f", "#875f5f", "bold", ["MatchParen"])

	hi! link StatusLineTerm StatusLine                    
	hi! link StatusLineTermNC StatusLineNC
	hi! link QuickFixLine Search
	hi! link VimFuncKey VimCommand
	hi! link VimSubstPat VimString

else

endif
