local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight on yank",
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
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
  pcall(vim.fn.serverstart, "./godothost")
end
