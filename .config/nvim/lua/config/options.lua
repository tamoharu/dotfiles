-- Language
vim.opt.langmenu = "en"
vim.cmd("language en_US.UTF-8")

-- Encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- History
vim.opt.history = 10000

-- UI
vim.o.winborder = "rounded"
vim.opt.number = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", extends = "»", precedes = "«", nbsp = "␣" }
vim.opt.fillchars:append({ diff = "╱" })

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Menu
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest", "list", "full" }

-- Indentation
vim.g.markdown_recommended_style = 0
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- File
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.autoread = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Mouse
vim.opt.mouse = "a"
vim.opt.mousemodel = "popup"

-- Filetype
vim.filetype.add({
	filename = {
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
	},
	pattern = {
		[".*git/config"] = "gitconfig",
		[".*git/ignore"] = "gitignore",
		[".*%.dockerignore"] = "gitignore",
		-- HACK: nvim launched with C-g in Claude Code
		-- [".*/claude%-prompt%-[^/]*%.md"] = { "text", { priority = 10 } },
	},
})

-- Cursor
vim.opt.guicursor = {
	"n-v-c-sm:block",
	"i-ci-ve:ver25",
	"r-cr-o:hor20",
	"a:blinkwait500-blinkoff500-blinkon500",
}

-- Options
vim.deprecate = function() end
