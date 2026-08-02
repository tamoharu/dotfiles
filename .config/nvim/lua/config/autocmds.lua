-- Auto reload
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave", "WinEnter" }, {
	callback = function()
		if vim.fn.mode() ~= "c" and vim.bo.buftype == "" then
			vim.cmd("checktime")
		end
	end,
	pattern = { "*" },
})

-- Reload buffer
vim.api.nvim_create_autocmd("FileChangedShell", {
	callback = function()
		vim.v.fcs_choice = "reload"
	end,
})

-- Clear stale diagnostics on LSP detach
vim.api.nvim_create_autocmd("LspDetach", {
	callback = function(ev)
		local ns = vim.lsp.diagnostic.get_namespace(ev.data.client_id)
		vim.diagnostic.reset(ns, ev.buf)
	end,
})

-- ESLint
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.mjs", "*.cjs" },
	callback = function(ev)
		local clients = vim.lsp.get_clients({ bufnr = ev.buf, name = "eslint" })
		if #clients == 0 then
			return
		end
		pcall(function()
			clients[1]:request_sync("workspace/executeCommand", {
				command = "eslint.applyAllFixes",
				arguments = {
					{
						uri = vim.uri_from_bufnr(ev.buf),
						version = vim.lsp.util.buf_versions[ev.buf],
					},
				},
			}, 3000, ev.buf)
		end)
	end,
})

-- Switch to ABC on nvim startup and on leaving insert/terminal/cmdline (macOS).
if vim.fn.has("mac") == 1 and vim.fn.executable("macism") == 1 then
	vim.api.nvim_create_autocmd({ "VimEnter", "InsertLeave", "TermLeave", "CmdlineLeave" }, {
		group = vim.api.nvim_create_augroup("AutoImeABC", { clear = true }),
		callback = function()
			vim.fn.jobstart({ "macism", "com.apple.keylayout.ABC" }, { detach = true })
		end,
	})
end

-- Reload snacks explorer
vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		local ok_g, Git = pcall(require, "snacks.explorer.git")
		if ok_g then
			for root in pairs(Git.state) do
				Git.state[root].last = 0
			end
		end
		local ok, snacks = pcall(require, "snacks")
		if ok and snacks.picker then
			for _, picker in ipairs(snacks.picker.get({ source = "explorer" })) do
				if not picker.closed then
					picker:action("explorer_update")
				end
			end
		end
	end,
})
