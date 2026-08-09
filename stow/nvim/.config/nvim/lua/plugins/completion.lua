return {
  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "none",
        ["<C-n>"] = { "select_next", "show" },
        ["<C-p>"] = { "select_prev", "show" },
        -- preset "none" opts out of blink's snippet keys too, so these have to
        -- be declared or placeholders are unreachable. Commands run in order
        -- and stop at the first one that returns true, and the two here are
        -- mutually exclusive: select_and_accept only succeeds with the menu
        -- open, snippet_forward only inside an active snippet. blink also binds
        -- these in select mode, where it skips non-snippet commands entirely
        -- (see blink/cmp/keymap/apply.lua).
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      snippets = { preset = "luasnip" },
      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        menu = {
          border = "rounded",
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
      require("blink.cmp").setup(opts)

      -- blink does NOT register its capabilities itself -- it only exposes
      -- get_lsp_capabilities(). Without this, servers see Neovim's defaults and
      -- lose `detail`/`data` in completionItem.resolveSupport, which servers
      -- that resolve lazily (Roslyn especially) use to fill in the menu.
      --
      -- `*` is merged into every client at start time, so this must run before
      -- the first client starts. It does, because blink is a start plugin; if
      -- it ever gains an `event`/`ft` trigger, move this back to config/lsp.lua.
      -- include_nvim_defaults=false: Neovim merges its own defaults already.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities({}, false),
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
}
