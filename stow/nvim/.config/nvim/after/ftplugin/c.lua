-- 4 spaces, matching the Allman clang-format style in lua/plugins/conform.lua.
-- Only affects typing and `==`; the formatter has the final say on write.
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.bo.expandtab = true

-- `setl x<` restores each option to its global value. Appended before the
-- `| lua` below, which has to stay last.
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | setl sw< sts< ts< et<"

-- Sourced only for C buffers, and only after $VIMRUNTIME/ftplugin/c.{lua,vim}.
-- The mapping is buffer-local, so it does not exist anywhere it would be
-- meaningless -- that is what replaces the old global mapping's
-- `if vim.bo.filetype ~= "c"` guard and its "Current buffer is not C." branch.
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("write")
  local src = vim.fn.shellescape(vim.fn.expand("%"))
  local out = vim.fn.shellescape(vim.fn.expand("%:r"))
  local exe = vim.fn.shellescape("./" .. vim.fn.expand("%:r"))
  vim.cmd(string.format("botright split | terminal cc -Wall -Wextra -std=c17 -g %s -o %s && %s", src, out, exe))
  vim.cmd("startinsert")
end, { buffer = true, desc = "Compile & run C file" })

-- Appended last on purpose: `:lua` swallows the rest of the line, so nothing can
-- be chained after it with `|`. The runtime ftplugin has already filled this in.
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | lua pcall(vim.keymap.del, 'n', '<leader>cc', { buffer = 0 })"
