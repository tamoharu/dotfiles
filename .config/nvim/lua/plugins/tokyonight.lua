return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			style = "night",
			transparent = true,
			terminal_colors = true,
			styles = {
				comments = { italic = false },
				keywords = { italic = false },
				functions = {},
				variables = {},
				sidebars = "transparent",
				floats = "transparent",
			},
			plugins = {
				auto = true,
			},
			on_highlights = function(hl, c)
				-- HACK: JSX/TSX
				hl["@tag.tsx"] = { fg = c.cyan }
				hl["@tag.javascript"] = { fg = c.cyan }
				-- HACK: html
				hl["@tag.builtin.tsx"] = { fg = c.red }
				hl["@tag.builtin.javascript"] = { fg = c.red }
				-- gitsigns
				hl.GitSignsAdd = { fg = c.green }
				hl.GitSignsChange = { fg = c.yellow }
				hl.GitSignsDelete = { fg = c.red }
				-- snacks explorer
				hl.SnacksPickerGitStatusUntracked = { fg = c.green }
				-- render-markdown: update inline code
				hl["@markup.raw.markdown_inline"] = { fg = c.blue }
				-- Dim panel
				-- TODO: fix
				hl.TroubleNormal = { fg = c.fg, bg = c.bg_dark }
				hl.TroubleNormalNC = { fg = c.fg, bg = c.bg_dark }
			end,
		})
		vim.cmd([[colorscheme tokyonight-night]])
	end,
}
