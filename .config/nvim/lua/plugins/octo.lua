return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
	},
	opts = {
		picker = "snacks",
		enable_builtin = true,
		use_timeline_icons = false,
	},
}
