-- Allman braces at 4 spaces. Kept in sync with the indent width set for typing
-- in after/ftplugin/c.lua; change both together or the formatter will fight the
-- editor on every save.
local allman = "{"
  .. table.concat({
    "BasedOnStyle: LLVM",
    "BreakBeforeBraces: Allman",
    "IndentWidth: 4",
    "TabWidth: 4",
    "UseTab: Never",
    -- LLVM collapses short constructs onto one line, which pulls the brace back
    -- up onto the header and undoes Allman for exactly the short cases.
    "AllowShortFunctionsOnASingleLine: None",
    "AllowShortIfStatementsOnASingleLine: false",
    "AllowShortLoopsOnASingleLine: false",
    "AllowShortBlocksOnASingleLine: Never",
  }, ", ")
  .. "}"

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
    formatters = {
      -- Passing no `--style` already means `--style=file`: clang-format walks up
      -- from the file looking for .clang-format and falls back to LLVM when it
      -- finds none. Only that fallback is wrong for us, and `--fallback-style`
      -- rejects anything but a predefined style name -- so the Allman override
      -- has to ride in on `--style`, which in turn has to be withheld whenever a
      -- project ships its own config, or it would override the project.
      ["clang-format"] = {
        prepend_args = function(_, ctx)
          local found = vim.fs.find({ ".clang-format", "_clang-format" }, {
            upward = true,
            path = ctx.dirname,
            type = "file",
          })
          if found[1] then
            return {}
          end
          return { "--style", allman }
        end,
      },
    },
  },
}
