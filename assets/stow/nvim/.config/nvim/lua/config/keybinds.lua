-- Key mappings
vim.g.mapleader = " "                              -- Set leader key to space
vim.g.maplocalleader = " "                         -- Set local leader key (NEW)
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')-- Clear highlights when pressing ESC

-- Lsp Stuff
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<leader><leader>", function()
  vim.fn.system({
    "zsh", "-lc",
    [[
      typst c *.typ &&
      cd ~/dotfiles &&
      git add -A &&
      git commit -m "Update dotfiles: $(date '+%Y-%m-%d %H:%M')" &&
      git push
    ]]
  })
end, { silent = true })

-- Quitting
vim.keymap.set("n", "<leader>q", ":quit<CR>", { desc = "Quitting" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer navigation
vim.keymap.set("n", "<C-]>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<C-[>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Quick file navigation
vim.keymap.set("n", "<leader>e", ":Oil<CR>", { desc = "Open file explorer" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting & Resizing
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move selected line(s) down(J)" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move selected line(s) up(K)" })
-- Formatting bash files
vim.keymap.set("n", "<leader>r", function()
  if vim.bo.filetype == "sh" then
    local view = vim.fn.winsaveview()
    vim.cmd("silent! %!shfmt -i 2 -ci")
    vim.fn.winrestview(view)
  else
    print("Not a shell script.")
  end
end, { desc = "Format shell script with shfmt" })
