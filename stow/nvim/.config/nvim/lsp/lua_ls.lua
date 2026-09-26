-- Neovim/plugin types and the LuaJIT runtime are injected by lazydev.nvim (see
-- lua/plugins/lazydev.lua), so no `vim` global or library paths are set here.
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  -- lazy-lock.json marks this config's root. Buffers here are opened through
  -- the stow symlinks in ~/.config/nvim, so the upward `.git` search never
  -- reaches ~/dev/dotfiles and would leave lua_ls in single-file mode.
  -- A .luarc.json would also work as a marker, but lua_ls lets it override the
  -- library paths lazydev injects.
  root_markers = { ".luarc.json", ".luarc.jsonc", "lazy-lock.json", ".git" },
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
