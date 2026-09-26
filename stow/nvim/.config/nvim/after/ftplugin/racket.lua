-- `<leader>cc`, same key as C and Typst: run the file in the shared REPL
-- (lua/config/racket.lua).
vim.keymap.set("n", "<leader>cc", function()
  require("config.racket").run()
end, { buffer = true, desc = "Run Racket file in REPL" })

-- $VIMRUNTIME/ftplugin/racket.vim maps K to `raco docs` (opens a browser),
-- and Neovim only adds its LSP hover K when K is unmapped. Drop the runtime one
-- so K is hover here too, like every other language.
pcall(vim.keymap.del, { "n", "x" }, "K", { buffer = true })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | lua pcall(vim.keymap.del, 'n', '<leader>cc', { buffer = 0 })"
