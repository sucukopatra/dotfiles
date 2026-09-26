local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })

map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up centered" })
map("n", "J", "mzJ`z", { desc = "Join lines keep cursor" })

-- "x" (Visual), not "v" (Visual + Select). Select mode is where vim.snippet
-- parks you on a placeholder, and there a printable key must replace the selection --
-- a "v" mapping here means K moves lines instead of typing K.
map("x", "<", "<gv", { desc = "Indent left and reselect" })
map("x", ">", ">gv", { desc = "Indent right and reselect" })
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ]b/[b (next/previous buffer) are Neovim defaults since 0.11.

-- :bdelete also closes every window showing the buffer, which collapses splits.
-- Point those windows at another buffer first so the layout survives.
local function delete_buffer(force)
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified and not force then
    local name = vim.fn.bufname(buf) ~= "" and vim.fn.fnamemodify(vim.fn.bufname(buf), ":t") or "[No Name]"
    local choice = vim.fn.confirm(("Save changes to %s?"):format(name), "&Yes\n&No\n&Cancel", 3)
    if choice == 1 then
      vim.cmd.write()
    elseif choice == 2 then
      force = true
    else
      return
    end
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      local alt = vim.fn.bufnr("#")
      if alt > 0 and alt ~= buf and vim.fn.buflisted(alt) == 1 then
        vim.cmd.buffer(alt)
      else
        vim.cmd.bprevious()
      end
      -- Only one listed buffer: nothing to fall back to, so leave an empty one.
      if vim.api.nvim_get_current_buf() == buf then
        vim.cmd.enew()
      end
    end)
  end
  vim.cmd((force and "bdelete! " or "bdelete ") .. buf)
end

map("n", "<leader>bd", function()
  delete_buffer(false)
end, { desc = "Delete buffer" })
map("n", "<leader>bD", function()
  delete_buffer(true)
end, { desc = "Delete buffer (force)" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Delete other buffers" })

map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Taller window" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shorter window" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Narrower window" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Wider window" })
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })

map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil explorer" })

-- The three most-used pickers get the top-level keys; the rest of the pickers
-- live under <leader>f.
map("n", "<leader><space>", "<cmd>FzfLua files<CR>", { desc = "Find files" })
map("n", "<leader>/", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>,", "<cmd>FzfLua buffers<CR>", { desc = "Find buffers" })

map("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>fc", "<cmd>FzfLua files cwd=~/.config/nvim<CR>", { desc = "Find Neovim config files" })
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
-- Both spellings: kitty's keyboard protocol delivers <C-/>, terminals without
-- it send the legacy byte for Ctrl-/, which Neovim reads as <C-_>.
for _, lhs in ipairs({ "<C-/>", "<C-_>" }) do
  map({ "n", "t" }, lhs, function()
    require("config.terminal").toggle()
  end, { desc = "Toggle terminal" })
end

-- <leader>u: toggles. Each one reports its new state, since most have no
-- other visible sign until something happens (a save, a diagnostic).
local function toggle(lhs, name, get, set)
  map("n", lhs, function()
    local on = not get()
    set(on)
    vim.notify(("%s: %s"):format(name, on and "on" or "off"))
  end, { desc = "Toggle " .. name:lower() })
end

toggle("<leader>uh", "Inlay hints", function()
  return vim.lsp.inlay_hint.is_enabled()
end, function(on)
  vim.lsp.inlay_hint.enable(on)
end)
toggle("<leader>ud", "Diagnostics", function()
  return vim.diagnostic.is_enabled()
end, function(on)
  vim.diagnostic.enable(on)
end)
-- Read by format_on_save in lua/plugins/conform.lua.
toggle("<leader>uf", "Format on save", function()
  return not vim.g.disable_autoformat
end, function(on)
  vim.g.disable_autoformat = not on
end)
toggle("<leader>uw", "Wrap", function()
  return vim.wo.wrap
end, function(on)
  vim.wo.wrap = on
end)
toggle("<leader>us", "Spell", function()
  return vim.wo.spell
end, function(on)
  vim.wo.spell = on
end)
toggle("<leader>ul", "Relative numbers", function()
  return vim.wo.relativenumber
end, function(on)
  vim.wo.relativenumber = on
end)
-- gitsigns flips its own setting and returns the new value, so no get/set pair.
map("n", "<leader>ub", function()
  local on = require("gitsigns").toggle_current_line_blame()
  vim.notify(("Line blame: %s"):format(on and "on" or "off"))
end, { desc = "Toggle line blame" })

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
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff file against index" })
map("n", "<leader>gD", function()
  require("gitsigns").diffthis("@")
end, { desc = "Diff file against last commit" })
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
-- stage_hunk toggles: on an already-staged hunk it unstages it.
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage/unstage hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
map("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage buffer" })
map("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })
-- Visual: act on just the selected lines, even part of a hunk.
map("x", "<leader>gs", function()
  require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage selected lines" })
map("x", "<leader>gr", function()
  require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset selected lines" })
map("n", "<leader>gq", "<cmd>Gitsigns setqflist all<CR>", { desc = "Hunks in repo to quickfix" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line full=true<CR>", { desc = "Blame line (full)" })
map("n", "<leader>gB", "<cmd>Gitsigns blame<CR>", { desc = "Blame file" })
map("n", "]h", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "Next git hunk" })
map("n", "[h", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Previous git hunk" })
map("n", "]H", "<cmd>Gitsigns nav_hunk last<CR>", { desc = "Last git hunk" })
map("n", "[H", "<cmd>Gitsigns nav_hunk first<CR>", { desc = "First git hunk" })
map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<CR>", { desc = "Inner git hunk" })

map("n", "<leader>cf", function()
  require("conform").format({ lsp_format = "fallback", async = true })
end, { desc = "Format buffer" })

-- `<leader>cc` (compile & run) is defined per-filetype in after/ftplugin/c.lua
-- and after/ftplugin/typst.lua, buffer-locally, so it only exists where it
-- works. `<leader>cf` above stays global because conform handles every filetype.
