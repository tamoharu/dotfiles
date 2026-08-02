return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle" },
	},
	init = function()
		vim.g.mkdp_auto_close = 0
		vim.g.mkdp_theme = "dark"
		vim.g.mkdp_browser = "Google Chrome"
	end,
}
