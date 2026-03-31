return {
  "stevearc/conform.nvim",
  opts = {
    notify_on_error = true,
    formatters_by_ft = {
      lua = { "stylua" },
      cs = { "csharpier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      typst = { "typstyle" },
    },
    format_on_save = nil,
  },
}
