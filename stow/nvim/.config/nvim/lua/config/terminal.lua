-- Terminals in a bottom split, of two kinds:
--
-- toggle(): one persistent shell, shown and hidden with the same key (Ctrl-/,
-- see config/keymaps.lua). Hiding closes only the window; the shell keeps
-- running in its buffer until you `exit` it.
--
-- run(): one throwaway window for `<leader>cc` (after/ftplugin/{c,racket}.lua).
-- Each run replaces the previous one in the same window and stops its process,
-- so the program always starts fresh.
local M = {}

local shell, output

local function split()
  vim.cmd("botright split")
  vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.3))
end

local function running()
  -- jobwait() with a 0 timeout returns -1 for a job that is still running.
  return vim.fn.jobwait({ vim.bo[shell].channel }, 0)[1] == -1
end

function M.toggle()
  local valid = shell and vim.api.nvim_buf_is_valid(shell)
  local win = valid and vim.fn.bufwinid(shell) or -1
  if win ~= -1 then
    vim.api.nvim_win_hide(win)
    return
  end

  -- A shell that has exited leaves its buffer behind whenever the exit status
  -- is non-zero (Neovim only auto-deletes on a clean exit, and a bare `exit`
  -- returns the last command's status), so check the job, not the buffer.
  if valid and not running() then
    vim.api.nvim_buf_delete(shell, { force = true })
    valid = false
  end

  split()
  if valid then
    vim.api.nvim_win_set_buf(0, shell)
  else
    vim.cmd.terminal()
    shell = vim.api.nvim_get_current_buf()
    vim.bo[shell].buflisted = false
  end
  vim.cmd.startinsert()
end

-- `cmd` is anything jobstart() takes: an argv list, or a string for the shell.
-- jobstart() rather than `:terminal {cmd}`: no Ex-cmdline expansion of `%` or
-- `#` in file names.
function M.run(cmd, cwd)
  local win = output and vim.fn.bufwinid(output) or -1
  if win ~= -1 then
    vim.api.nvim_set_current_win(win)
  else
    split()
  end

  -- Wiped, which stops its process, once the next run replaces it or its
  -- window is closed.
  output = vim.api.nvim_create_buf(false, true)
  vim.bo[output].bufhidden = "wipe"
  vim.api.nvim_win_set_buf(0, output)
  vim.fn.jobstart(cmd, { term = true, cwd = cwd })
  vim.cmd.startinsert()
end

return M
