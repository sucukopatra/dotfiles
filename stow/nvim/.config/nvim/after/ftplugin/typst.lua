-- `<leader>cc`, not the old `<leader>tc`: this is the same operation C has, so it
-- belongs under the same which-key group ("Code") rather than in a `<leader>t`
-- group that existed to hold one mapping. Both are buffer-local, so the two
-- definitions never collide.
--
-- The runtime ftplugin already ran `:compiler typst`, so 'makeprg' is
-- `typst compile --diagnostic-format short %:S`: the path is shell-escaped and
-- errors land in the quickfix list. `make!` stays put instead of jumping to the
-- first error; `cwindow` opens the list only when there is something in it, and
-- closes a stale one after a clean build.
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("write")
  vim.cmd("silent make!")
  vim.cmd("redraw!")
  vim.cmd("cwindow")
end, { buffer = true, desc = "Compile Typst file" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | lua pcall(vim.keymap.del, 'n', '<leader>cc', { buffer = 0 })"
