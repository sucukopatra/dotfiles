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

-- clang's `file:line:col: error: message` lines. Anything else (linker errors)
-- is kept as plain text, minus the "N errors generated." tally.
local EFM = "%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m,%f:%l:%c: %m,%-G%.%#generated."

vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("write")
  -- Built next to the source, like `make50` run there. Errors go to the
  -- quickfix list (]q to jump); a clean build runs in the bottom run window.
  -- -fno-caret-diagnostics only drops the source excerpts from the messages.
  local dir = vim.fn.expand("%:p:h")
  local exe = vim.fn.expand("%:t:r")
  local argv = vim.list_extend({ CC, "-fno-caret-diagnostics" }, CFLAGS)
  vim.list_extend(argv, { "-o", exe, vim.fn.expand("%:p") })
  vim.list_extend(argv, LDLIBS)
  local res = vim.system(argv, { cwd = dir, text = true }):wait()
  if res.code ~= 0 then
    local lines = vim.split(res.stderr, "\n", { trimempty = true })
    vim.fn.setqflist({}, " ", { title = "clang", lines = lines, efm = EFM })
    vim.cmd("copen")
    return
  end
  vim.cmd("cclose")
  require("config.terminal").run({ "./" .. exe }, dir)
end, { buffer = true, desc = "Compile & run C file (make50 flags)" })
