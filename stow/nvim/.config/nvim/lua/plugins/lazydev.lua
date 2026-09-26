-- Configures lua_ls for editing this config: Neovim's runtime types, plus the
-- types of any plugin that is `require`d (or named in a ---@module annotation)
-- in an open buffer, added to the workspace library on demand.
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- libuv types, only once `vim.uv` appears in a buffer.
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    -- Completes module names inside require("...") and ---@module "...".
    -- `sources.default` is appended to, not replaced: completion.lua lists it
    -- in opts_extend.
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lazydev" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
}
