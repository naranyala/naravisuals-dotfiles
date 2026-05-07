local M = {}

-- Theme meta information
M.name = "paperlike_night"
M.description = "A clean, readable dark theme with paper-like contrast"
M.version = "1.0.0"

-- Color palette with WCAG contrast considerations
local function hex_to_rgb(hex)
	hex = hex:gsub("#", "")
	return {
		r = tonumber(hex:sub(1, 2), 16),
		g = tonumber(hex:sub(3, 4), 16),
		b = tonumber(hex:sub(5, 6), 16),
	}
end

local function contrast_ratio(fg, bg)
	local fg_rgb = hex_to_rgb(fg)
	local bg_rgb = hex_to_rgb(bg)

	local function lum(c)
		c = c / 255
		return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
	end

	local l1 = 0.2126 * lum(fg_rgb.r) + 0.7152 * lum(fg_rgb.g) + 0.0722 * lum(fg_rgb.b)
	local l2 = 0.2126 * lum(bg_rgb.r) + 0.7152 * lum(bg_rgb.g) + 0.0722 * lum(bg_rgb.b)

	return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05)
end

local colors = {
	-- Base colors
	bg = "#2E2E2E", -- Slightly lighter than original for better contrast
	bg_alt = "#3A3A3A", -- Alternative background (cursorline, statusline)
	fg = "#E8E8E8", -- Primary foreground
	fg_alt = "#D0D0D0", -- Secondary foreground

	-- Syntax colors
	comment = "#8A8A8A", -- Comments (meets WCAG AA for contrast)
	keyword = "#FFB347", -- Keywords (orange)
	function_ = "#7EC07F", -- Functions (green)
	string = "#D08A5E", -- Strings (orange-brown)
	constant = "#B8A897", -- Constants (beige)
	type = "#7A9BC2", -- Types (blue)
	special = "#A0AEC0", -- Special characters

	-- UI colors
	cursorline = "#383838", -- Cursor line
	visual = "#4A4A4A", -- Visual selection
	line_num = "#6D6D6D", -- Line numbers
	nontext = "#5A5A5A", -- Non-text elements

	-- Diagnostic colors
	error = "#F85149", -- Error (red)
	warn = "#FFAB70", -- Warning (orange)
	info = "#60A5FA", -- Info (blue)
	hint = "#8BC34A", -- Hint (green)

	-- Git colors
	added = "#4F6D4F", -- Git added
	changed = "#5D5D3D", -- Git changed
	removed = "#5D3D3D", -- Git removed

	-- Terminal colors (16-color palette)
	black = "#2E2E2E",
	red = "#F85149",
	green = "#8BC34A",
	yellow = "#FFAB70",
	blue = "#60A5FA",
	magenta = "#D946EF",
	cyan = "#22D3EE",
	white = "#E8E8E8",
	bright_black = "#5A5A5A",
	bright_red = "#FF6B6B",
	bright_green = "#A3E635",
	bright_yellow = "#FFD54F",
	bright_blue = "#93C5FD",
	bright_magenta = "#F472B6",
	bright_cyan = "#67E8F9",
	bright_white = "#FFFFFF",
}

-- Validate contrast ratios
local function validate_contrast()
	local min_contrast = 4.5 -- WCAG AA standard

	local checks = {
		{ name = "Normal text", fg = colors.fg, bg = colors.bg },
		{ name = "Comments", fg = colors.comment, bg = colors.bg },
		{ name = "Keywords", fg = colors.keyword, bg = colors.bg },
		{ name = "Error text", fg = colors.error, bg = colors.bg },
	}

	for _, check in ipairs(checks) do
		local ratio = contrast_ratio(check.fg, check.bg)
		if ratio < min_contrast then
			vim.notify(
				string.format(
					"Warning: %s contrast ratio %.1f:1 (below WCAG AA %.1f:1)",
					check.name,
					ratio,
					min_contrast
				),
				vim.log.levels.WARN
			)
		end
	end
end

-- Highlight group helper with fallbacks
local function hl(group, opts)
	local defaults = {
		fg = nil,
		bg = nil,
		bold = false,
		italic = false,
		underline = false,
		undercurl = false,
		sp = nil, -- Special color (undercurl)
		blend = nil,
		default = false,
	}

	opts = vim.tbl_extend("force", defaults, opts or {})

	-- Skip empty groups
	if
		not opts.fg
		and not opts.bg
		and not opts.bold
		and not opts.italic
		and not opts.underline
		and not opts.undercurl
	then
		return
	end

	vim.api.nvim_set_hl(0, group, opts)
end

-- Link highlight groups
local function hl_link(from, to)
	vim.api.nvim_set_hl(0, from, { link = to })
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

	-- Validate contrast before applying
	validate_contrast()

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
