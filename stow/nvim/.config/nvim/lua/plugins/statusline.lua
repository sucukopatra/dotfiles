return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  opts = {
    options = {
      -- "auto" derives the palette from the active colourscheme's highlight
      -- groups. Naming "rose-pine" here instead would load a theme file shipped
      -- by the *colourscheme* plugin, not by lualine -- an undeclared
      -- cross-plugin dependency that only resolves because rose-pine carries
      -- priority = 1000. Under rose-pine the two produce identical colours
      -- (42/42 entries), and "auto" keeps following if the colourscheme changes.
      theme = "auto",
      globalstatus = true,
      component_separators = "|",
      section_separators = "",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = {
        -- Restores the passive "updates are pending" signal that was lost when
        -- lua/config/lazy.lua set checker.notify = false. lazy.status reads the
        -- same Checker.updated list the notification used, so the checker needs
        -- no extra work -- but unlike the popup this reports continuously
        -- instead of once per launch, and only when there is something to say.
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          -- updates() returns `false`, not "", when nothing is pending; `cond`
          -- is what keeps that out of the statusline.
          -- No on_click: lualine registers click handlers through the
          -- deprecated vim.validate{} form (removed in Nvim 1.0). <leader>l
          -- opens :Lazy instead.
        },
        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
