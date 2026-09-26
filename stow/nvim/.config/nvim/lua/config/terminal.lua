-- One persistent shell in a bottom split, shown and hidden with the same key
-- (Ctrl-/, see config/keymaps.lua). Hiding closes only the window; the shell
-- keeps running in its buffer until you `exit` it.
local M = {}

local buf

local function find_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
end

local function running()
  -- jobwait() with a 0 timeout returns -1 for a job that is still running.
  return vim.fn.jobwait({ vim.bo[buf].channel }, 0)[1] == -1
end

function M.toggle()
  local valid = buf and vim.api.nvim_buf_is_valid(buf)
  local win = valid and find_win()
  if win then
    vim.api.nvim_win_hide(win)
    return
  end

  -- A shell that has exited leaves its buffer behind whenever the exit status
  -- is non-zero (Neovim only auto-deletes on a clean exit, and a bare `exit`
  -- returns the last command's status), so check the job, not the buffer.
  if valid and not running() then
    vim.api.nvim_buf_delete(buf, { force = true })
    valid = false
  end

  vim.cmd("botright split")
  vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.3))
  if valid then
    vim.api.nvim_win_set_buf(0, buf)
  else
    vim.cmd.terminal()
    buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buflisted = false
  end
  vim.cmd.startinsert()
end

return M
