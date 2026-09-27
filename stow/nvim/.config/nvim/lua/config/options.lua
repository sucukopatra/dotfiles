vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
-- Scroll wrapped lines by screen line, not a whole paragraph at a time.
vim.opt.smoothscroll = true
vim.opt.signcolumn = "yes"
-- Default border for every floating window that doesn't pick its own: LSP
-- hover/signature, diagnostics, gitsigns popups, and blink, mason and oil
-- (all three fall back to this when their `border` is left nil).
vim.opt.winborder = "rounded"

-- Default for filetypes with no stronger opinion (lua, typst, json/toml). C and
-- C# get 4 spaces from ~/.editorconfig (stow/nvim/.editorconfig).
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.writebackup = false
vim.opt.swapfile = false
-- Undo files land in stdpath("state")/undo, which Neovim creates itself.
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10

-- Every yank *and* every delete goes to the system clipboard -- that is all
-- "unnamedplus" does, and no setting mirrors yanks only. Decided: worth it.
-- After an intervening delete, `"0p` still pastes the last yank inside Neovim,
-- but the system clipboard itself will be holding the deleted text.
vim.opt.clipboard = "unnamedplus"
vim.opt.confirm = true

vim.opt.splitbelow = true
vim.opt.splitright = true

-- Folding is set up per-buffer by the treesitter FileType autocmd; open
-- everything by default so folds only appear when asked for (za/zc/zM).
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""

vim.opt.wildmode = "longest:full,full"
-- `:e`/`:find` completion only; FzfLua uses `fd` and .gitignore instead.
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
})
