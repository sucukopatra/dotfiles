return {
  "stevearc/conform.nvim",
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      local enabled = { c = true, typst = true }
      if not enabled[vim.bo[bufnr].filetype] then
        return
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      c = { "clang-format" },
--      cs = { "csharpier" },
      python = { "ruff" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      typst = { "typstyle" },
    },
  },
}
