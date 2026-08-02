return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = function()
			local servers = {
				"lua_ls",
				"vtsls",
				"denols",
				"eslint",
				"cssls",
				"html",
				"jsonls",
				"taplo",
				"dockerls",
				"docker_compose_language_service",
				"tailwindcss",
			}

			-- macOS
			if vim.fn.has("mac") == 1 then
				vim.list_extend(servers, {
					"ruby_lsp",
					"basedpyright",
					"ruff",
				})
			end

			return {
				ensure_installed = servers,
				automatic_enable = true,
			}
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				-- Formatters
				"stylua",
				"prettierd",
				"sql-formatter",
				-- Linters
				"hadolint",
			},
		},
	},
}
