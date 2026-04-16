local M = {}

local function run_cmd(cmd)
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify(("AI command failed: %s (%s)"):format(cmd, err), vim.log.levels.WARN)
  end
end

function M.disable_all_inline()
  run_cmd("Codeium Disable")
  vim.notify("Inline AI disabled", vim.log.levels.INFO)
end

function M.toggle_codeium()
  run_cmd("Codeium Toggle")
end

function M.toggle_claude_code()
  run_cmd("ClaudeCode")
end

function M.setup()
  vim.api.nvim_create_user_command("AIToggleCodeium", M.toggle_codeium, { desc = "Toggle Codeium inline suggestions" })
  vim.api.nvim_create_user_command("AIDisableInline", M.disable_all_inline, { desc = "Disable inline AI providers" })
  vim.api.nvim_create_user_command("AIToggleClaudeCode", M.toggle_claude_code, { desc = "Toggle Claude Code" })
end

return M
