return {
  {
    "mason-org/mason.nvim",
    -- Must load before the first FileType: setup() prepends mason's bin dir to
    -- vim.env.PATH, and every server/formatter in this config is resolved from
    -- there by bare name. VeryLazy fires on VimEnter, which is too late for the
    -- buffer nvim was started with.
    lazy = false,
    priority = 100,
    opts = {
      ui = {
        border = "rounded",
      },
      registries = {
        "github:mason-org/mason-registry",
        -- Carries `roslyn`/`roslyn-nightly`, which track the language server
        -- version shipped with the VS Code C# extension.
        "github:Crashdummyy/mason-registry",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- The registry fetch is the slow part, and nothing needs it during startup.
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "bash-language-server",
        "basedpyright",
        "clangd",
        "clang-format",
        "codelldb",
        "csharpier",
        "gdtoolkit",
        "lua-language-server",
        "netcoredbg",
        "roslyn",
        "ruff",
        "shfmt",
        "stylua",
        "tinymist",
        "typstyle",
      },
      run_on_start = true,
      auto_update = false,
      start_delay = 3000,
    },
  },
}
