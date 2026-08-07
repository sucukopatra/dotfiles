-- C# language support via the Roslyn language server (the same server behind
-- the VS Code C# extension). Requires the .NET SDK and the `roslyn` Mason
-- package; see lua/plugins/mason.lua.
--
-- Server settings live in ~/.config/nvim/lsp/roslyn.lua like every other
-- server; only plugin-level behaviour is configured here.
return {
  "seblyng/roslyn.nvim",
  ft = { "cs" },
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    -- Unity writes its .sln next to Assets/, so allow searching downward for
    -- it when nvim is opened from somewhere other than the project root.
    broad_search = true,
    -- Let the server watch files instead of Neovim. A Unity project's
    -- Library/ and Temp/ trees are far too large for the built-in watcher.
    filewatching = "roslyn",
  },
}
