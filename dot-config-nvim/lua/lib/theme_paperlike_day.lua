local M = {}

-- Theme meta information
M.name = "paperlike_day"
M.description = "A clean, readable light theme with paper-like aesthetics"
M.version = "1.0.0"

-- Color palette with WCAG contrast considerations
local colors = {
	-- Base colors
	bg = "#F5F5F5", -- Soft white paper background
	bg_alt = "#EAEAEA", -- Slightly darker for contrast
	fg = "#333333", -- Dark gray for text
	fg_alt = "#555555", -- Secondary text

	-- Syntax colors
	comment = "#888888", -- Comments (meets WCAG AA)
	keyword = "#D35400", -- Keywords (burnt orange)
	function_ = "#2980B9", -- Functions (blue)
	string = "#C45A00", -- Strings (orange-brown)
	constant = "#8E44AD", -- Constants (purple)
	type = "#27AE60", -- Types (green)
	special = "#7F8C8D", -- Special characters

	-- UI colors
	cursorline = "#E0E0E0", -- Cursor line
	visual = "#D4D4D4", -- Visual selection
	line_num = "#9E9E9E", -- Line numbers
	nontext = "#B0B0B0", -- Non-text elements

	-- Diagnostic colors
	error = "#C0392B", -- Error (red)
	warn = "#F39C12", -- Warning (orange)
	info = "#3498DB", -- Info (blue)
	hint = "#16A085", -- Hint (teal)

	-- Git colors
	added = "#D5E8D5", -- Git added
	changed = "#F5F5D5", -- Git changed
	removed = "#F8D8D8", -- Git removed

	-- Terminal colors (16-color palette)
	white = "#F5F5F5",
	black = "#333333",
	red = "#C0392B",
	green = "#27AE60",
	yellow = "#F39C12",
	blue = "#2980B9",
	magenta = "#8E44AD",
	cyan = "#16A085",
	bright_white = "#FFFFFF",
	bright_black = "#7F8C8D",
	bright_red = "#E74C3C",
	bright_green = "#2ECC71",
	bright_yellow = "#F1C40F",
	bright_blue = "#3498DB",
	bright_magenta = "#9B59B6",
	bright_cyan = "#1ABC9C",
}

-- Highlight group helper
local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

M.setup = function()
	-- Basic setup
	vim.o.termguicolors = true
	vim.g.colors_name = M.name

	-- Clear existing highlights
	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end

	-- Base UI ------------------------------------------------------------------
	hl("Normal", { fg = colors.fg, bg = colors.bg })
	hl("NormalFloat", { fg = colors.fg, bg = colors.bg_alt })
	hl("NormalNC", { link = "Normal" })

	-- Cursor
	hl("Cursor", { fg = colors.bg, bg = colors.fg })
	hl("CursorLine", { bg = colors.cursorline })
	hl("CursorColumn", { link = "CursorLine" })
	hl("CursorLineNr", { fg = colors.keyword, bg = colors.cursorline, bold = true })

	-- Line numbers
	hl("LineNr", { fg = colors.line_num, bg = colors.bg })
	hl("LineNrAbove", { link = "LineNr" })
	hl("LineNrBelow", { link = "LineNr" })

	-- Window UI
	hl("WinSeparator", { fg = colors.nontext, bg = colors.bg })
	hl("VertSplit", { link = "WinSeparator" })
	hl("FloatBorder", { fg = colors.nontext, bg = colors.bg_alt })

	-- Pmenu (completion)
	hl("Pmenu", { fg = colors.fg, bg = colors.bg_alt })
	hl("PmenuSel", { fg = colors.bg, bg = colors.keyword, bold = true })
	hl("PmenuSbar", { bg = colors.bg_alt })
	hl("PmenuThumb", { bg = colors.nontext })

	-- Search
	hl("Search", { fg = colors.bg, bg = colors.keyword })
	hl("IncSearch", { fg = colors.bg, bg = colors.function_, bold = true })
	hl("CurSearch", { link = "IncSearch" })

	-- Visual mode
	hl("Visual", { bg = colors.visual })
	hl("VisualNOS", { link = "Visual" })

	-- Statusline
	hl("StatusLine", { fg = colors.fg, bg = colors.bg_alt })
	hl("StatusLineNC", { fg = colors.comment, bg = colors.bg_alt })
	hl("StatusLineTerm", { link = "StatusLine" })
	hl("StatusLineTermNC", { link = "StatusLineNC" })

	-- Tabline
	hl("TabLine", { fg = colors.comment, bg = colors.bg_alt })
	hl("TabLineSel", { fg = colors.keyword, bg = colors.bg, bold = true })
	hl("TabLineFill", { bg = colors.bg })

	-- Syntax highlights --------------------------------------------------------
	hl("Comment", { fg = colors.comment, italic = true })
	hl("Keyword", { fg = colors.keyword })
	hl("Function", { fg = colors.function_ })
	hl("String", { fg = colors.string })
	hl("Constant", { fg = colors.constant })
	hl("Type", { fg = colors.type })
	hl("Identifier", { fg = colors.fg })
	hl("Statement", { fg = colors.keyword })
	hl("PreProc", { fg = colors.keyword })
	hl("Special", { fg = colors.special })
	hl("Delimiter", { fg = colors.fg })
	hl("Operator", { fg = colors.fg })

	-- Tree-sitter highlights ---------------------------------------------------
	hl("@comment", { link = "Comment" })
	hl("@keyword", { link = "Keyword" })
	hl("@function", { link = "Function" })
	hl("@function.call", { link = "Function" })
	hl("@method", { link = "Function" })
	hl("@method.call", { link = "Function" })
	hl("@string", { link = "String" })
	hl("@constant", { link = "Constant" })
	hl("@constant.builtin", { fg = colors.constant, italic = true })
	hl("@type", { link = "Type" })
	hl("@type.builtin", { fg = colors.type, italic = true })
	hl("@variable", { fg = colors.fg })
	hl("@parameter", { fg = colors.fg_alt })
	hl("@property", { fg = colors.constant })
	hl("@punctuation.delimiter", { fg = colors.fg_alt })
	hl("@punctuation.bracket", { fg = colors.fg_alt })
	hl("@tag", { fg = colors.keyword })
	hl("@tag.delimiter", { fg = colors.fg_alt })

	-- LSP highlights -----------------------------------------------------------
	hl("DiagnosticError", { fg = colors.error, undercurl = true })
	hl("DiagnosticWarn", { fg = colors.warn, undercurl = true })
	hl("DiagnosticInfo", { fg = colors.info, undercurl = true })
	hl("DiagnosticHint", { fg = colors.hint, undercurl = true })
	hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.error })
	hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.warn })
	hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.info })
	hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.hint })

	hl("LspReferenceText", { bg = colors.visual })
	hl("LspReferenceRead", { bg = colors.visual })
	hl("LspReferenceWrite", { bg = colors.visual, bold = true })

	-- Git highlights -----------------------------------------------------------
	hl("DiffAdd", { bg = colors.added })
	hl("DiffChange", { bg = colors.changed })
	hl("DiffDelete", { bg = colors.removed })
	hl("DiffText", { bg = colors.changed, bold = true })

	hl("GitSignsAdd", { fg = colors.hint })
	hl("GitSignsChange", { fg = colors.warn })
	hl("GitSignsDelete", { fg = colors.error })

	-- Terminal colors ----------------------------------------------------------
	for i = 0, 15 do
		local color_key = ({
			[0] = "black",
			[1] = "red",
			[2] = "green",
			[3] = "yellow",
			[4] = "blue",
			[5] = "magenta",
			[6] = "cyan",
			[7] = "white",
			[8] = "bright_black",
			[9] = "bright_red",
			[10] = "bright_green",
			[11] = "bright_yellow",
			[12] = "bright_blue",
			[13] = "bright_magenta",
			[14] = "bright_cyan",
			[15] = "bright_white",
		})[i]

		vim.g["terminal_color_" .. i] = colors[color_key]
	end

	-- Plugin support -----------------------------------------------------------

	-- nvim-cmp
	hl("CmpItemAbbr", { fg = colors.fg })
	hl("CmpItemAbbrDeprecated", { fg = colors.comment, strikethrough = true })
	hl("CmpItemAbbrMatch", { fg = colors.function_, bold = true })
	hl("CmpItemAbbrMatchFuzzy", { fg = colors.function_, bold = true })
	hl("CmpItemKind", { fg = colors.type })
	hl("CmpItemMenu", { fg = colors.comment })

	-- Telescope
	hl("TelescopeBorder", { link = "FloatBorder" })
	hl("TelescopeSelection", { link = "Visual" })

	-- Indent blankline
	hl("IndentBlanklineChar", { fg = colors.nontext })
	hl("IndentBlanklineContextChar", { fg = colors.fg_alt })

	-- Notify
	hl("NotifyERRORBorder", { fg = colors.error })
	hl("NotifyWARNBorder", { fg = colors.warn })
	hl("NotifyINFOBorder", { fg = colors.info })
	hl("NotifyDEBUGBorder", { fg = colors.comment })
	hl("NotifyTRACEBorder", { fg = colors.special })

	vim.notify(string.format("%s theme v%s loaded", M.name, M.version), vim.log.levels.INFO)
end

return M
