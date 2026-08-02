return {
	"echasnovski/mini.icons",
	lazy = false,
	opts = {
		filetype = {
			env = { glyph = "\xEF\x91\xA2", hl = "MiniIconsYellow" },
		},
	},
	init = function()
		package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
		end
	end,
}
