vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.showmatch = true
vim.g.have_nerd_font = true
vim.opt.winblend = 0

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10
vim.opt.autoread = true
vim.opt.autowrite = false

vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.confirm = true
vim.opt.inccommand = "nosplit"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

vim.opt.wildmenu = true
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

vim.opt.signcolumn = "yes"

local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
