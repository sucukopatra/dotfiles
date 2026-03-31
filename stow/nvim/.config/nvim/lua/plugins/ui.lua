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
        { "<leader>a", group = "AI" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find/Format" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Harpoon" },
        { "<leader>s", group = "Split" },
        { "<leader>t", group = "Typst" },
        { "<leader>x", group = "Trouble" },
      })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      winopts = {
        border = "rounded",
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
    "echasnovski/mini.icons",
    opts = {},
  },
}
