return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
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
		local root = vim.fs.root(bufname, {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			"eslint.config.mts",
			"eslint.config.cts",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yaml",
			".eslintrc.yml",
			".eslintrc.json",
			".eslintrc",
		})
		if root then
			on_dir(root)
		end
	end,
	settings = {
		validate = "on",
		packageManager = nil,
		useESLintClass = false,
		experimental = {
			useFlatConfig = true,
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = false,
		quiet = false,
		onIgnoredFiles = "off",
		rulesCustomizations = {},
		run = "onType",
		problems = {
			shortenToSingleLine = false,
		},
		nodePath = vim.NIL, -- Node.js v24
		workingDirectory = { mode = "auto" },
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
	},
}
