return {
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    opts = {
      ui = {
        border = "rounded",
      },
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "bash-language-server",
        "basedpyright",
        "clangd",
        "clang-format",
        "lua-language-server",
        "ruff",
        "shfmt",
        "stylua",
        "tinymist",
        "typstyle",
        --        "roslyn",
        --        "omnisharp",
        --        "csharpier",
      },
      run_on_start = true,
      auto_update = false,
      start_delay = 3000,
    },
  },
--  {
--    "seblyng/roslyn.nvim",
--    ft = { "cs", "razor" },
--    dependencies = { "williamboman/mason.nvim" },
--    config = function()
--      local ok, roslyn = pcall(require, "roslyn")
--      if not ok then
--        vim.notify("roslyn.nvim not available. Use :LspUseOmniSharp as fallback.", vim.log.levels.WARN)
--        return
--      end
-- 
--      roslyn.setup({
--        broad_search = true,
--        filewatching = "roslyn",
--        config = {
--          capabilities = require("config.lsp").capabilities(),
--        },
--      })
--    end,
--  },
}
