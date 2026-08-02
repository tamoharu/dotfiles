return {
	cmd = { "vtsls", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_dir = function(bufnr, on_dir)
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if vim.fs.root(bufname, { "deno.json", "deno.jsonc" }) then
			return
		end
		local root = vim.fs.root(bufname, { "tsconfig.json", "package.json", "jsconfig.json", ".git" })
		if root then
			on_dir(root)
		end
	end,
	settings = {
		typescript = {
			tsserver = { maxTsServerMemory = 8092 },
			experimental = {
				completion = {
					enableServerSideFuzzyMatch = true,
					entriesLimit = 5000,
				},
			},
			suggest = { completeFunctionCalls = true },
		},
		javascript = {
			tsserver = { maxTsServerMemory = 8092 },
			experimental = {
				completion = {
					enableServerSideFuzzyMatch = true,
					entriesLimit = 5000,
				},
			},
			suggest = { completeFunctionCalls = true },
		},
		vtsls = {
			autoUseWorkspaceTsdk = true,
		},
	},
}
