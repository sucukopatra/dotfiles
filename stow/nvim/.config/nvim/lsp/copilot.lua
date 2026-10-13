---@param client vim.lsp.Client
---@param bufnr integer
local function sign_in(client, bufnr)
  ---@diagnostic disable-next-line: param-type-mismatch
  client:request("signIn", vim.empty_dict(), function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end
    if result.status == "AlreadySignedIn" then
      vim.notify("Copilot: already signed in as " .. result.user)
      return
    end
    if not result.command then
      vim.notify(("Copilot: enter code %s at %s"):format(result.userCode, result.verificationUri))
      return
    end
    vim.fn.setreg("+", result.userCode)
    local open = vim.fn.confirm(
      ("Copilot: one-time code %s copied to clipboard.\nOpen the browser to finish signing in?"):format(result.userCode),
      "&Yes\n&No"
    )
    if open ~= 1 then
      return
    end
    client:exec_cmd(result.command, { bufnr = bufnr }, function(cmd_err, cmd_result)
      if cmd_err then
        vim.notify(cmd_err.message, vim.log.levels.ERROR)
      elseif cmd_result.status == "OK" then
        vim.notify("Copilot: signed in as " .. cmd_result.user)
      end
    end)
  end)
end

---@param client vim.lsp.Client
local function sign_out(client)
  ---@diagnostic disable-next-line: param-type-mismatch
  client:request("signOut", vim.empty_dict(), function(err)
    if err then
      vim.notify(err.message, vim.log.levels.ERROR)
    else
      vim.notify("Copilot: signed out")
    end
  end)
end

---@type vim.lsp.Config
return {
  cmd = { "copilot-language-server", "--stdio" },
  root_markers = { ".git" },
  init_options = {
    editorInfo = { name = "Neovim", version = tostring(vim.version()) },
    editorPluginInfo = { name = "Neovim", version = tostring(vim.version()) },
  },
  settings = {
    telemetry = { telemetryLevel = "off" },
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "CopilotSignIn", function()
      sign_in(client, bufnr)
    end, { desc = "Sign in to GitHub Copilot" })
    vim.api.nvim_buf_create_user_command(bufnr, "CopilotSignOut", function()
      sign_out(client)
    end, { desc = "Sign out of GitHub Copilot" })
  end,
}
