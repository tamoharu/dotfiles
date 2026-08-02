local opts = { buffer = 0, silent = true }

vim.keymap.set("n", "<leader>jq", ":%!jq .<CR>", vim.tbl_extend("force", opts, { desc = "Format JSON with jq" }))
