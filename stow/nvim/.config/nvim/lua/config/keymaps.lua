local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })

map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })
map("n", "J", "mzJ`z", { desc = "Join lines keep cursor" })

-- "x" (Visual), not "v" (Visual + Select). Select mode is where LuaSnip parks
-- you on a placeholder, and there a printable key must replace the selection --
-- a "v" mapping here means K moves lines instead of typing K.
map("x", "<", "<gv", { desc = "Indent left and reselect" })
map("x", ">", ">gv", { desc = "Indent right and reselect" })
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Delete buffer (force)" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Delete other buffers" })

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
map("n", "<leader>fv", "<cmd>FzfLua files cwd=~/.config/nvim<CR>", { desc = "Find Neovim config files" })
map("n", "<leader>fn", "<cmd>FzfLua files cwd=~/notes<CR>", { desc = "Find notes" })
map("n", "<leader>f.", "<cmd>FzfLua resume<CR>", { desc = "Resume last picker" })
map("n", "<leader>fw", "<cmd>FzfLua grep_cword<CR>", { desc = "Grep word under cursor" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", { desc = "Document diagnostics" })
map("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "Document symbols" })
map("n", "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", { desc = "Workspace symbols" })
map("n", "<leader>fk", "<cmd>FzfLua keymaps<CR>", { desc = "Keymaps" })
map("n", "<leader>fu", "<cmd>FzfLua undotree<CR>", { desc = "Undo tree" })

map("n", "<leader>l", "<cmd>Lazy<CR>", { desc = "Open Lazy" })
map("n", "<leader>m", "<cmd>Mason<CR>", { desc = "Open Mason" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics (Trouble)" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Symbols (Trouble)" })
map(
  "n",
  "<leader>xl",
  "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
  { desc = "LSP locations (Trouble)" }
)
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list (Trouble)" })

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview" })
map("n", "<leader>gD", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line full=true<CR>", { desc = "Blame line (full)" })
map("n", "<leader>gB", "<cmd>Gitsigns blame<CR>", { desc = "Blame file" })
map("n", "]h", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "Next git hunk" })
map("n", "[h", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Previous git hunk" })
map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<CR>", { desc = "Inner git hunk" })

map("n", "<leader>cf", function()
  require("conform").format({ lsp_format = "fallback", async = true })
end, { desc = "Format buffer" })

-- `<leader>cc` (compile & run) is defined per-filetype in after/ftplugin/c.lua
-- and after/ftplugin/typst.lua, buffer-locally, so it only exists where it
-- works. `<leader>cf` above stays global because conform handles every filetype.
