local M = {}

function M.capabilities()
  local base = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    return blink.get_lsp_capabilities(base)
  end
  return base
end

function M.setup()
  local capabilities = M.capabilities()

  vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
  vim.lsp.enable("lua_ls")

  vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git", "package.json" },
    capabilities = capabilities,
  })
  vim.lsp.enable("jsonls")

  vim.lsp.config("bashls", {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash", "zsh" },
    root_markers = { ".git" },
    capabilities = capabilities,
  })
  vim.lsp.enable("bashls")

  vim.lsp.config("tinymist", {
    cmd = { "tinymist" },
    filetypes = { "typst", "typ" },
    root_markers = { ".git", "typst.toml" },
    capabilities = capabilities,
  })
  vim.lsp.enable("tinymist")

  vim.lsp.config("omnisharp", {
    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
    filetypes = { "cs" },
    root_markers = { "*.sln", "*.csproj", ".git" },
    capabilities = capabilities,
    settings = {
      FormattingOptions = {
        EnableEditorConfigSupport = true,
        OrganizeImports = true,
      },
    },
  })

  vim.api.nvim_create_user_command("LspUseOmniSharp", function()
    vim.lsp.enable("omnisharp")
    vim.notify("OmniSharp enabled for C# buffers.", vim.log.levels.INFO)
  end, { desc = "Enable OmniSharp fallback for C#" })
end

return M
