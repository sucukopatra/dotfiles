return {
  "stevearc/conform.nvim",
  -- Safe only because lazy.nvim *replays* the triggering event once the plugin
  -- is loaded (lazy/core/handler/event.lua:132) -- it re-fires BufWritePre for
  -- every augroup that did not already exist when the event was captured, which
  -- is exactly conform's own. Without that replay the first `:w` of a session
  -- would silently skip formatting. `<leader>cf` needs no `keys` entry: it calls
  -- require("conform") directly, which lazy's module hook loads on demand.
  event = { "BufWritePre" },
  cmd = "ConformInfo",
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      local enabled = { c = true, cs = true, typst = true }
      if not enabled[vim.bo[bufnr].filetype] then
        return
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      c = { "clang-format" },
      cs = { "csharpier" },
      gdscript = { "gdformat" },
      -- `ruff` on its own is conform's deprecated alias for `ruff_fix`, which
      -- runs `ruff check --fix --exit-zero` -- lint autofixes, never a format.
      -- Order matters: fix, then sort imports, then format the result.
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      typst = { "typstyle" },
    },
  },
}
