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
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeDiff" },
    config = function()
      require("claude-code").setup()
    end,
  },
}
