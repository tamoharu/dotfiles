return {
	-- Mason's RubyGems shim can miss its sibling Ruby executable on macOS.
	-- Use the Ruby and ruby-lsp managed together by mise instead.
	cmd = { "mise", "exec", "--", "ruby-lsp" },
	filetypes = { "ruby", "eruby" },
	root_markers = { "Gemfile", ".git" },
	init_options = {
		formatter = "auto",
		linters = { "rubocop" },
	},
}
