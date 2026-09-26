return {
  {
    "saghen/blink.cmp",
    version = "*",
    -- Snippets use blink's default engine (Neovim's vim.snippet). Its snippet
    -- source loads friendly-snippets from the runtimepath, plus VS Code-style
    -- JSON from stdpath("config")/snippets -- snippets/cs.json holds the Unity ones.
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "none",
        ["<C-n>"] = { "select_next", "show" },
        ["<C-p>"] = { "select_prev", "show" },
        -- preset "none" opts out of blink's snippet keys too, so these have to
        -- be declared or placeholders are unreachable. Commands run in order
        -- and stop at the first one that returns true.
        --
        -- snippet_forward goes first: inside a placeholder the menu can be
        -- open too (typing a word that matches a snippet or LSP item), and
        -- accepting there would paste that item mid-snippet instead of moving
        -- on. Use <CR> to accept inside a snippet. snippet_forward only
        -- succeeds when there *is* a next placeholder -- vim.snippet ends the
        -- session at $0 or when the cursor leaves the snippet -- so everywhere
        -- else Tab falls through to select_and_accept as before. blink also
        -- binds these in select mode, where it skips non-snippet commands
        -- entirely (see blink/cmp/keymap/apply.lua).
        ["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
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
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)
      -- In Racket ' and ` are quote prefixes ('(1 2), `(a ,b)), not delimiters.
      -- Conditions run in order and the first non-nil answer wins, so this has
      -- to go first to override the rules' own "pair here" checks.
      local cond = require("nvim-autopairs.conds")
      for _, char in ipairs({ "'", "`" }) do
        for _, rule in ipairs(npairs.get_rules(char)) do
          rule:with_pair(cond.not_filetypes({ "racket" }), 1)
        end
      end
    end,
  },
}
