-- Run the file in a fresh REPL in the bottom run window (config/terminal.lua),
-- like DrRacket's Run button. It lands inside the module, so its definitions
-- (provided or not) can be called directly. `main` and `test` submodules run
-- first when present.
--
-- No errortrace: it recompiles every library loaded after it from source, and
-- those builds clash with the precompiled ones already loaded (rackunit fails
-- with "instantiate-linklet: mismatch"). Runtime errors still name the failing
-- function's file:line in their context lines.
-- stylua: ignore
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("write")
  local function str(s)
    return '"' .. s:gsub('[\\"]', "\\%0") .. '"'
  end
  local file = str(vim.fn.expand("%:p"))
  local helper = str(vim.fn.stdpath("config") .. "/racket/repl.rkt")
  require("config.terminal").run({
    "racket",
    -- The REPL starts output on a fresh line before its prompt, but only knows
    -- the column once line counting is on; it turns that on itself too late
    -- for the -e output, so a bare `(printf "hi")` got drawn over.
    "-e", "(port-count-lines! (current-output-port))",
    "-e", ("(require (file %s))"):format(helper),
    "-e", ("(prepare %s)"):format(file),
    "-e", ("(enter! (file %s))"):format(file),
    "-i",
  }, vim.fn.expand("%:p:h"))
end, { buffer = true, desc = "Run Racket file in REPL" })

-- $VIMRUNTIME/ftplugin/racket.vim maps K to `raco docs` (opens a browser),
-- and Neovim only adds its LSP hover K when K is unmapped. Drop the runtime one
-- so K is hover here too, like every other language.
pcall(vim.keymap.del, { "n", "x" }, "K", { buffer = true })
