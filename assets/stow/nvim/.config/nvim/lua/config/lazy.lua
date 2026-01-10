local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- C#
vim.lsp.config("roslyn", {
  filetypes = { "cs" },
})
vim.lsp.enable("roslyn")

-- Typst
vim.api.nvim_create_autocmd("FileType", { pattern = { "typst", "typ" }, callback = function(args) vim.lsp.start({ name = "tinymist", cmd = { "tinymist" }, root_dir = vim.fn.getcwd(), }) end, })
vim.lsp.enable("tinymist")

-- Lua
vim.lsp.config("lua", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
})
vim.lsp.enable("lua")

-- Python
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
})
vim.lsp.enable("pyright")

require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },

  change_detection = { notify = false },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
