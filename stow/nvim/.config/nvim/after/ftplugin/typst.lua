-- `<leader>cc`, not the old `<leader>tc`: this is the same operation C has, so it
-- belongs under the same which-key group ("Code") rather than in a `<leader>t`
-- group that existed to hold one mapping. Both are buffer-local, so the two
-- definitions never collide.
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("write")
  vim.cmd("silent !typst compile %")
  vim.cmd("checktime")
end, { buffer = true, desc = "Compile Typst file" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | lua pcall(vim.keymap.del, 'n', '<leader>cc', { buffer = 0 })"
