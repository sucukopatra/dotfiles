return {
  "stevearc/conform.nvim",
  -- lazy.nvim replays the BufWritePre that loads it, so the first `:w` formats.
  event = { "BufWritePre" },
  cmd = "ConformInfo",
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Flipped by <leader>uf (config/keymaps.lua).
      if vim.g.disable_autoformat then
        return
      end
      local ft = vim.bo[bufnr].filetype
      -- shfmt would split every `{ a; b; }` one-liner; shell stays on <leader>cf.
      if ft == "sh" or ft == "bash" or ft == "zsh" then
        return
      end
      -- ruff_fix deletes an import on the save right after you add it, before
      -- anything uses it; it stays on <leader>cf.
      if ft == "python" then
        return { timeout_ms = 1000, formatters = { "ruff_organize_imports", "ruff_format" } }
      end
      return { timeout_ms = 1000 }
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
