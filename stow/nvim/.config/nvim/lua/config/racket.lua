-- One Racket REPL in a bottom split, shared by every Racket buffer and driven
-- by <leader>cc (after/ftplugin/racket.lua). Each run replaces the REPL in the
-- same window and stops the old process, so the program always starts fresh.
local M = {}

local buf

local function find_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
end

-- Lands in a REPL inside the module, so its definitions (provided or not) can
-- be called directly. `main` and `test` submodules run first when present.
--
-- No errortrace: it recompiles every library loaded after it from source, and
-- those builds clash with the precompiled ones already loaded (rackunit fails
-- with "instantiate-linklet: mismatch"). Runtime errors still name the failing
-- function's file:line in their context lines.
function M.run()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local mod = ('(file "%s")'):format((file:gsub('[\\"]', "\\%0")))
  local run_subs = ("(for ([s '(main test)]) (define m `(submod %s ,s))"
    .. " (when (module-declared? m #t) (dynamic-require m #f)))"):format(mod)

  local win = buf and vim.api.nvim_buf_is_valid(buf) and find_win()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("botright split")
    vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.3))
  end

  local old = buf
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.jobstart({
    "racket",
    "-e", ("(enter! %s)"):format(mod),
    "-e", run_subs,
    "-i",
  }, { term = true, cwd = dir })
  -- Wiping a terminal buffer also stops its job.
  if old and vim.api.nvim_buf_is_valid(old) then
    vim.api.nvim_buf_delete(old, { force = true })
  end
  vim.cmd("startinsert")
end

return M
