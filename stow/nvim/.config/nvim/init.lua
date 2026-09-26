-- Experimental 0.12 messages/cmdline UI: no "Press ENTER" prompts, long
-- messages collapse to `[+N]` (`g<` opens them in the pager). First, so it is
-- in place before anything below prints. Delete this line to go back.
require("vim._core.ui2").enable({})

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("config.lsp")
