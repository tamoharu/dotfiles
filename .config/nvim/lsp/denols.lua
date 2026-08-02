return {
	cmd = { "deno", "lsp" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "deno.json", "deno.jsonc" },
	workspace_required = true,
	settings = {
		deno = {
			enable = true,
		},
	},
}
