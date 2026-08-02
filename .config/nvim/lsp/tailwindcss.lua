return {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = {
		"tailwind.config.js",
		"tailwind.config.ts",
		"tailwind.config.mjs",
		"postcss.config.js",
		"postcss.config.ts",
		".git",
	},
	settings = {
		tailwindCSS = {
			classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
			validate = true,
			lint = {
				cssConflict = "ignore",
			},
		},
	},
}
