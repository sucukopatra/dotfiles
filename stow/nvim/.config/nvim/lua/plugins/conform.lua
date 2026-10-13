local manual_only = { sh = true, bash = true, zsh = true }

return {
  "stevearc/conform.nvim",
  -- lazy.nvim replays the BufWritePre that loads it, so the first `:w` formats.
  event = { "BufWritePre" },
  cmd = "ConformInfo",
  opts = {
    format_on_save = function(bufnr)
      -- vim.g.disable_autoformat is flipped by <leader>uf (config/keymaps.lua).
      -- Shell is <leader>cf only: shfmt splits every `{ a; b; }` one-liner.
      if vim.g.disable_autoformat or manual_only[vim.bo[bufnr].filetype] then
        return
      end
      return { timeout_ms = 1000 }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      c = { "clang-format" },
      cs = { "csharpier" },
      gdscript = { "gdformat" },
      python = { "ruff_organize_imports", "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      typst = { "typstyle" },
    },
    formatters = {
      shfmt = { prepend_args = { "-i", "2", "-ci" } },
    },
  },
}
