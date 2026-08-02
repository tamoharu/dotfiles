return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup({
			preset = "modern",
			win = {
				border = "rounded",
			},
			expand = function()
				return true
			end,
		})
	end,
}
