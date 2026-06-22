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

  vim.lsp.config("basedpyright", {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", ".git" },
    capabilities = capabilities,
    settings = {
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  })
  vim.lsp.enable("basedpyright")

  vim.lsp.config("clangd", {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders=true",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = {
      ".clangd",
      "compile_commands.json",
      "compile_flags.txt",
      "Makefile",
      "configure.ac",
      ".git",
    },
    capabilities = capabilities,
  })
  vim.lsp.enable("clangd")

  vim.lsp.config("gdscript", {
    cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
    filetypes = { "gdscript", "gd" },
    root_markers = { "project.godot" },
    capabilities = capabilities,
  })
  vim.lsp.enable("gdscript")

--  vim.lsp.config("omnisharp", {
--    cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
--    filetypes = { "cs" },
--    root_markers = { "*.sln", "*.csproj", ".git" },
--    capabilities = capabilities,
--    settings = {
--      FormattingOptions = {
--        EnableEditorConfigSupport = true,
--        OrganizeImports = true,
--      },
--    },
--  })
-- 
--  vim.api.nvim_create_user_command("LspUseOmniSharp", function()
--    vim.lsp.enable("omnisharp")
--    vim.notify("OmniSharp enabled for C# buffers.", vim.log.levels.INFO)
--  end, { desc = "Enable OmniSharp fallback for C#" })

  local map = vim.keymap.set
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    callback = function(args)
      local opts = { buffer = args.buf }
      map("n", "K",          vim.lsp.buf.hover,         vim.tbl_extend("force", opts, { desc = "LSP hover" }))
      map("n", "gd",         vim.lsp.buf.definition,    vim.tbl_extend("force", opts, { desc = "LSP definition" }))
      map("n", "gD",         vim.lsp.buf.declaration,   vim.tbl_extend("force", opts, { desc = "LSP declaration" }))
      map("n", "gr",         vim.lsp.buf.references,    vim.tbl_extend("force", opts, { desc = "LSP references" }))
      map("n", "gi",         vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "LSP implementation" }))
      map("n", "<leader>ca", vim.lsp.buf.code_action,   vim.tbl_extend("force", opts, { desc = "LSP code action" }))
      map("n", "<leader>cr", vim.lsp.buf.rename,        vim.tbl_extend("force", opts, { desc = "LSP rename" }))
      map("n", "<leader>cd", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))
      map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
      map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,  vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
    end,
  })
end

return M
