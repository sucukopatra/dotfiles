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
