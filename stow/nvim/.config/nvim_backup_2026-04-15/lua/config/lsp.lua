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
    filetypes = { "typst" },
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

  local map = vim.keymap.set
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    callback = function(args)
      local opts = { buffer = args.buf }
      map("n", "K",          vim.lsp.buf.hover,       vim.tbl_extend("force", opts, { desc = "LSP hover" }))
      map("n", "gd",         vim.lsp.buf.definition,  vim.tbl_extend("force", opts, { desc = "LSP definition" }))
      map("n", "gD",         vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "LSP declaration" }))
      map("n", "gr",         vim.lsp.buf.references,  vim.tbl_extend("force", opts, { desc = "LSP references" }))
      map("n", "gi",         vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "LSP implementation" }))
      map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP code action" }))
      map("n", "<leader>rn", vim.lsp.buf.rename,      vim.tbl_extend("force", opts, { desc = "LSP rename" }))
      map("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))
      map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
      map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,  vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
    end,
  })
end

return M
