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
      registries = {
        "github:mason-org/mason-registry",
        -- Carries `roslyn`/`roslyn-nightly`, which track the language server
        -- version shipped with the VS Code C# extension.
        --
        -- Deliberately unpinned. Mason does support `@<tag>` here, but pinning
        -- would only stop *new* roslyn versions arriving on a fresh install --
        -- `auto_update = false` below already keeps the installed server put --
        -- while costing a manual bump forever. It would not change the trust
        -- relationship: the binary is this author's build either way.
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
      -- No clangd/clang-format: both come from Arch's `clang` package (listed in
      -- the dotfiles' packages.conf), the same LLVM version as the clang that
      -- builds CS50 code, so editor diagnostics and formatting match the
      -- compiler and the terminal. A Mason copy would shadow them on PATH.
      ensure_installed = {
        "bash-language-server",
        "basedpyright",
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
    -- run_on_start is normally driven by a VimEnter autocmd in the plugin's
    -- plugin/ file, but VeryLazy fires *after* VimEnter, so that autocmd is
    -- registered too late and never runs. Kick it off by hand instead;
    -- run_on_start() still honours the run_on_start flag and start_delay.
    config = function(_, opts)
      local mti = require("mason-tool-installer")
      mti.setup(opts)
      mti.run_on_start()
    end,
  },
}
