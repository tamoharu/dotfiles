-- Continue list markers on <CR>
-- Runtime ftplugin sets `fb:` (no repeat) and `fo-=r`, which disables it
vim.opt_local.comments = "b:*,b:-,b:+,b:1.,n:>"
vim.opt_local.formatoptions:append("r")

-- <C-d> is remapped to <Del> for Emacs-style insert, so pair <C-t> with <C-S-t>
-- Requires the kitty keyboard protocol to tell <C-S-t> from <C-t>
vim.keymap.set("i", "<C-S-t>", "<C-d>", { buffer = true, desc = "Dedent" })
