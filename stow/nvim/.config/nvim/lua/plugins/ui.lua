return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 200,
      preset = "modern",
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Harpoon" },
        { "<leader>s", group = "Split" },
        { "<leader>u", group = "Toggles" },
        { "<leader>x", group = "Diagnostics" },
      })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-mini/mini.icons" },
    opts = {
      winopts = {
        preview = {
          layout = "vertical",
          vertical = "down:55%",
        },
      },
      fzf_opts = {
        ["--info"] = "inline-right",
      },
      files = {
        cwd_prompt = false,
      },
      keymap = {
        fzf = {
          ["ctrl-q"] = "select-all+accept",
        },
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    opts = {},
    config = function(_, opts)
      local icons = require("mini.icons")
      icons.setup(opts)
      -- fzf-lua and oil support mini.icons directly, but lualine, trouble and
      -- which-key only ever ask for nvim-web-devicons -- and they do it behind a
      -- pcall, so a missing provider costs an icon with no error. The mock
      -- registers mini.icons under that module name to fill the gap.
      --
      -- No load-order handling is needed: all three require it from inside a
      -- render function, not at module level, so the mock is always in place by
      -- the time the first statusline is drawn.
      icons.mock_nvim_web_devicons()
    end,
  },
}
