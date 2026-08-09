local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
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
  -- Keep checking for updates, but silently: `notify` defaults to true, which
  -- pops a "# Plugin Updates" window once per launch for as long as anything is
  -- out of date. The hourly re-check never notifies (lazy calls report() with no
  -- argument), so this only ever cost startup noise. Pending updates are still
  -- listed in `:Lazy` -- checker.updated is populated before the notify gate.
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- Matched against the basename of each plugin/*.{lua,vim} file found
      -- while walking the runtimepath (lazy/core/loader.lua:450), so a name
      -- with no corresponding file is silently inert. Every entry below
      -- resolves to a real file in $VIMRUNTIME/plugin.
      --
      -- Deliberately NOT disabled: net.lua, which is 0.12's built-in
      -- replacement for netrw's `:e https://…` handling -- dropping netrwPlugin
      -- without keeping net.lua would lose remote-file editing entirely.
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tutor",
        "netrwPlugin",
      },
    },
  },
})
