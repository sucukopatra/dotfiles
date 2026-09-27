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
      -- lualine, trouble and which-key only know nvim-web-devicons.
      icons.mock_nvim_web_devicons()
    end,
  },
}
