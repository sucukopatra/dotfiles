local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

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

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = {
    colorscheme = { "rose-pine" },
  },
  -- No plugin here ships a rockspec, and luarocks isn't installed, so leaving
  -- this on only earns a :checkhealth ERROR. Re-enable if a plugin needs it.
  rocks = { enabled = false },
  -- Silent: pending updates show in the statusline and `:Lazy` instead of a
  -- popup on every launch.
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
