return {
  {
    "Exafunction/windsurf.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "InsertEnter",
    cmd = "Codeium",
    config = function()
      require("codeium").setup({
        enable_cmp_source = false,
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = "<C-l>",
            accept_word = "<C-f>",
            accept_line = "<C-S-l>",
            dismiss = "<C-e>",
          },
        },
      })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    opts = {
      provider = "gemini",
      providers = {
        gemini = {
          model = "gemini-2.5-flash",
          api_key_name = "GEMINI_API_KEY",
        },
      },
      windows = {
        position = "right",
        width = 42,
      },
    },
  },
}
