-- Server definitions live in ~/.config/nvim/lsp/<name>.lua and are picked up
-- from 'runtimepath' automatically; see :h lsp-config.
--
-- Completion capabilities are not set here: blink.cmp's plugin/blink-cmp.lua
-- registers them with vim.lsp.config('*') when blink loads. That has to happen
-- before the first client starts, which holds while blink is a start plugin;
-- if it ever gains an `event`/`ft` trigger, set them here instead.
vim.lsp.enable({
  "basedpyright",
  "bashls",
  "clangd",
  "gdscript",
  "lua_ls",
  "racket_langserver",
  "tinymist",
})

-- Neovim already maps K, ]d, [d, gO and the gr* family out of the box -- grn
-- rename, gra code action, grr references, gri implementation, grt type
-- definition, grx code lens -- plus <C-w>d for line diagnostics (see
-- :h lsp-defaults). Those are used as-is, so only the additions live here.
-- Inlay hints are toggled by <leader>uh (config/keymaps.lua).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  desc = "Buffer-local LSP keymaps",
  callback = function(args)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "LSP definition")
    map("gD", vim.lsp.buf.declaration, "LSP declaration")

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- enable() drives its own refresh lifecycle, so no BufEnter/InsertLeave
    -- autocmd is needed (refresh() is deprecated in 0.12, gone in 0.13).
    if client:supports_method("textDocument/codeLens") then
      vim.lsp.codelens.enable(true, { bufnr = args.buf })
      map("<leader>cl", vim.lsp.codelens.run, "Run code lens")
    end
  end,
})
