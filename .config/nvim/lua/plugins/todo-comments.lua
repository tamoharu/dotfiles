return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		signs = false,
		highlight = {
			comments_only = false,
			pattern = {
				[[.*<(KEYWORDS)\s*:]],
				[=[.*>\s*\[!TODO\]]=], -- `> [!TODO]`
			},
		},
		search = {
			pattern = [=[\b(KEYWORDS):|>\s*\[!TODO\]]=],
		},
	},
}
