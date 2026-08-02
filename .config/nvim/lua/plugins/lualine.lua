return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"echasnovski/mini.icons",
	},
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			tabline = {
				lualine_a = { "tabs" },
			},
			options = {
				always_show_tabline = false,
				theme = "tokyonight",
				globalstatus = true,
				component_separators = "",
				section_separators = "",
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1,
					},
				},
				lualine_x = {
					{
						"lsp_status",
						icon = "",
						ignore_lsp = { "GitHub Copilot", "eslint", "stylua" },
						fmt = function(str)
							if str == "" then
								return ""
							end
							if vim.o.columns < 120 then
								return "LSP"
							end
							return str
						end,
					},
					"encoding",
					{
						"fileformat",
						symbols = {
							unix = "LF",
							dos = "CRLF",
							mac = "CR",
						},
					},
					{ "filetype", icon_only = true },
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
