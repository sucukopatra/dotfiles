local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })

map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })
map("n", "J", "mzJ`z", { desc = "Join lines keep cursor" })

map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "<C-]>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<C-[>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })

map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil explorer" })

map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>fn", "<cmd>FzfLua files cwd=~/.config/nvim<CR>", { desc = "Find Neovim config files" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics (Trouble)" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Symbols (Trouble)" })
map("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", { desc = "LSP locations (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list (Trouble)" })

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview" })
map("n", "<leader>gD", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
map("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
map("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
map("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous git hunk" })

map("n", "<leader>ha", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon:list():add()
  end
end, { desc = "Harpoon add current file" })

map("n", "<leader>hh", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end
end, { desc = "Harpoon quick menu" })

map("n", "<A-1>", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon:list():select(1)
  end
end, { desc = "Harpoon file 1" })

map("n", "<A-2>", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon:list():select(2)
  end
end, { desc = "Harpoon file 2" })

map("n", "<A-3>", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon:list():select(3)
  end
end, { desc = "Harpoon file 3" })

map("n", "<A-4>", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon:list():select(4)
  end
end, { desc = "Harpoon file 4" })

map("n", "<C-p>", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon:list():prev()
  end
end, { desc = "Harpoon previous" })

map("n", "<C-n>", function()
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    harpoon:list():next()
  end
end, { desc = "Harpoon next" })

map("n", "<leader>f", function()
  require("conform").format({ lsp_fallback = true, async = true })
end, { desc = "Format buffer" })

map("n", "<leader>tc", function()
  if vim.bo.filetype == "typst" then
    vim.cmd("write")
    vim.cmd("silent !typst compile %")
    vim.cmd("checktime")
  else
    vim.notify("Current buffer is not Typst.", vim.log.levels.INFO)
  end
end, { desc = "Compile Typst file" })

map("n", "<leader>ae", function()
  require("config.ai").activate_codeium()
end, { desc = "Enable Codeium suggestions" })

map("n", "<leader>at", function()
  require("config.ai").toggle_codeium()
end, { desc = "Toggle Codeium" })

map("n", "<leader>aa", function()
  require("config.ai").disable_all_inline()
end, { desc = "Disable all inline AI" })

map("n", "<leader>av", function()
  require("config.ai").toggle_avante()
end, { desc = "Toggle Avante" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(args)
    local opts = { buffer = args.buf }

    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP hover" }))
    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "LSP definition" }))
    map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "LSP declaration" }))
    map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "LSP references" }))
    map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "LSP implementation" }))
    map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP code action" }))
    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP rename" }))
    map("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
  end,
})
