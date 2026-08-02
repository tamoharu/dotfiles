return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			json = { "prettierd" },
			html = { "prettierd" },
			css = { "prettierd" },
			markdown = { "prettierd" },
			yaml = { "prettierd" },
			python = { "ruff_format" },
			toml = { "taplo" },
			sql = { "sql_formatter" },
		},
		formatters = {
			sql_formatter = {
				prepend_args = { "-l", "postgresql" },
			},
		},
		format_on_save = {
			timeout_ms = 3000,
			lsp_format = "fallback",
		},
	},
}
