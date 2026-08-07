-- Server definitions live in ~/.config/nvim/lsp/<name>.lua and are picked up
-- from 'runtimepath' automatically; see :h lsp-config.
--
-- Completion capabilities are not set here: blink.cmp registers them globally
-- via vim.lsp.config('*') from its own plugin file.
vim.lsp.enable({
  "basedpyright",
  "bashls",
  "clangd",
  "gdscript",
  "lua_ls",
  "tinymist",
})

-- Neovim already maps K, ]d, [d, grn, gra, grr, gri and gO out of the box
-- (see :h lsp-defaults), so only the additions live here.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  desc = "Buffer-local LSP keymaps",
  callback = function(args)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "LSP definition")
    map("gD", vim.lsp.buf.declaration, "LSP declaration")
    map("<leader>ca", vim.lsp.buf.code_action, "LSP code action")
    map("<leader>cr", vim.lsp.buf.rename, "LSP rename")
    map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Servers are asked to compute these (see lsp/roslyn.lua, lsp/clangd.lua);
    -- without enabling them client-side the results are simply discarded.
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      map("<leader>ch", function()
        local on = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
        vim.lsp.inlay_hint.enable(not on, { bufnr = args.buf })
      end, "Toggle inlay hints")
    end

    -- enable() drives its own refresh lifecycle, so no BufEnter/InsertLeave
    -- autocmd is needed (refresh() is deprecated in 0.12, gone in 0.13).
    if client:supports_method("textDocument/codeLens") then
      vim.lsp.codelens.enable(true, { bufnr = args.buf })
      map("<leader>cl", vim.lsp.codelens.run, "Run code lens")
    end
  end,
})
