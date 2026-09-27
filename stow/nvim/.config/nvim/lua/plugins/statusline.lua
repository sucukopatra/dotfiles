return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  opts = {
    options = {
      globalstatus = true,
      component_separators = "|",
      section_separators = "",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = {
        -- Pending plugin updates (lazy.lua's checker doesn't notify).
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
        },
        -- Attached servers, with a spinner until each finishes loading.
        "lsp_status",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
