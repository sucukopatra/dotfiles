-- 4 spaces, matching csharpier. Moved here from a FileType autocmd in
-- config/autocmds.lua: that autocmd was registered from init.lua and so ran
-- *before* $VIMRUNTIME/ftplugin/cs.lua, which is the wrong side of the runtime
-- defaults to be setting options on. An after/ftplugin runs last by definition.
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.tabstop = 4
vim.bo.expandtab = true

-- `setl x<` restores each option to its global value, undoing the four above if
-- the filetype changes. The runtime ftplugin has already set b:undo_ftplugin.
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | setl sw< sts< ts< et<"
