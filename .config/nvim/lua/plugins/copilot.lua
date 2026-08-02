return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = false,
					keymap = {
						accept = "<Tab>",
						accept_word = false,
						accept_line = false,
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
				},
				panel = { enabled = false },
				filetypes = {
					["*"] = true,
					["env"] = false,
					["gitcommit"] = false,
				},
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.b.copilot_suggestion_auto_trigger = true
				end,
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = "zbirenbaum/copilot.lua",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
