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
--
-- Mirrors the `make50` alias in the dotfiles' stow/zsh/.zshrc (CS50's own
-- flags, libcs50 from the Arch package); change both together.
local CC = "clang"
local CFLAGS = {
  "-fsanitize=signed-integer-overflow",
  "-fsanitize=undefined",
  "-ggdb3",
  "-O0",
  "-std=c11",
  "-Wall",
  "-Werror",
  "-Wextra",
  "-Wno-sign-compare",
  "-Wno-unused-parameter",
  "-Wno-unused-variable",
  "-Wshadow",
}
local LDLIBS = { "-lcrypt", "-lcs50", "-lm" }

vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("write")
  -- Build and run from the source's own directory, like `make50` run next to
  -- it: works however the file was opened, and errors read `hello.c:7:13`.
  local dir = vim.fn.expand("%:p:h")
  local src = vim.fn.expand("%:t")
  local exe = vim.fn.expand("%:t:r")
  local argv = vim.list_extend({ CC }, CFLAGS)
  vim.list_extend(argv, { "-o", exe, src })
  vim.list_extend(argv, LDLIBS)
  local compile = table.concat(vim.tbl_map(vim.fn.shellescape, argv), " ")
  vim.cmd("botright new")
  -- jobstart() rather than `:terminal {cmd}`: no Ex-cmdline expansion of `%`
  -- or `#` in file names.
  vim.fn.jobstart(compile .. " && " .. vim.fn.shellescape("./" .. exe), {
    term = true,
    cwd = dir,
  })
  vim.cmd("startinsert")
end, { buffer = true, desc = "Compile & run C file (make50 flags)" })

-- Appended last on purpose: `:lua` swallows the rest of the line, so nothing can
-- be chained after it with `|`. The runtime ftplugin has already filled this in.
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | lua pcall(vim.keymap.del, 'n', '<leader>cc', { buffer = 0 })"
