return {
	"dlyongemallo/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	config = function()
		local c = require("tokyonight.colors").setup()

		-- Theme
		vim.api.nvim_set_hl(0, "DiffviewFilePanelTitle", { fg = c.dark5 })
		vim.api.nvim_set_hl(0, "DiffviewFilePanelCounter", { fg = c.dark5 })
		vim.api.nvim_set_hl(0, "DiffviewFilePanelRootPath", { fg = c.dark5 })
		vim.api.nvim_set_hl(0, "DiffviewFilePanelPath", { fg = c.dark5 })
		vim.api.nvim_set_hl(0, "DiffviewFilePanelFileName", { fg = c.fg })

		require("diffview").setup({
			enhanced_diff_hl = true,
			show_help_hints = false,
			use_icons = false,
			file_panel = {
				listing_style = "list",
				win_config = {
					width = 25,
				},
			},
			hooks = {
				diff_buf_win_enter = function(_, winid)
					vim.wo[winid].cursorline = false
					local existing = vim.wo[winid].winhl
					if existing ~= "" then
						vim.wo[winid].winhl = existing .. ",Folded:Comment"
					else
						vim.wo[winid].winhl = "Folded:Comment"
					end
				end,
			},
		})
	end,
}
