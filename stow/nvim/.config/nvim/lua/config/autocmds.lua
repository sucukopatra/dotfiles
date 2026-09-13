local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight on yank",
  callback = function()
    vim.hl.on_yank()
  end,
})

local no_restore = {
  gitcommit = true, -- COMMIT_EDITMSG, MERGE_MSG, TAG_EDITMSG
  gitrebase = true, -- git-rebase-todo
  gitsendemail = true, -- .gitsendemail.msg
}

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position",
  callback = function(args)
    if no_restore[vim.filetype.match({ buf = args.buf }) or ""] then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup,
  desc = "Check for external file changes",
  command = "checktime",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  desc = "Create missing parent directories on write",
  callback = function(args)
    -- Skip oil://, fugitive:// and friends; only real paths need a mkdir.
    if args.match:match("^%w%w+://") then
      return
    end
    vim.fn.mkdir(vim.fn.fnamemodify(args.match, ":p:h"), "p")
  end,
})

-- Indentation follows each language's own convention, which is whatever its
-- formatter emits. Only the filetypes that disagree with the 2-space default in
-- config/options.lua need an entry: Neovim's built-in ftplugins already set
-- python to 4 spaces and gdscript to tabs, and shfmt/typstyle match the default.
-- The two that need one are C# (csharpier) and C (Allman clang-format), both at
-- 4 spaces, and both live in after/ftplugin/, which is sourced after the runtime
-- ftplugin rather than before it.

-- Kept as an autocmd rather than three near-identical after/ftplugin files: one
-- pattern list is the clearer expression of "these filetypes are prose".
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown", "typst", "gitcommit" },
  desc = "Spell check and wrap prose",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Godot's "external editor" opens files by talking to a running Neovim over a
-- socket. Point Godot at this project's `godothost` file under
-- Editor Settings > Text Editor > External, with:
--   Exec Path:  nvim
--   Exec Flags: --server ./godothost --remote-send
--               "<C-\><C-N>:n {file}<CR>:call cursor({line},{col})<CR>"
-- Add `godothost` to the project's .gitignore.
if vim.uv.fs_stat(vim.fn.getcwd() .. "/project.godot") then
  local ok, err = pcall(vim.fn.serverstart, "./godothost")
  if not ok then
    vim.schedule(function()
      vim.notify(("Godot external editor inactive: %s"):format((err:gsub("^Vim:", ""))), vim.log.levels.WARN)
    end)
  end
end
