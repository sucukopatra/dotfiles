vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

-- Fallback only: .editorconfig wins where a project ships one, and treesitter's
-- indentexpr (set by the FileType autocmd) overrides indent calculation.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
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

vim.opt.mouse = "a"
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
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

vim.diagnostic.config({
  signs = true,
  underline = true,
  virtual_text = true,
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded" },
})
