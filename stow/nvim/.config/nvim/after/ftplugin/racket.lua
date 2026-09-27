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
  local file = vim.fn.expand("%:p")
  local mod = ('(file "%s")'):format((file:gsub('[\\"]', "\\%0")))
  local run_subs = ("(for ([s '(main test)]) (define m `(submod %s ,s))"
    .. " (when (module-declared? m #t) (dynamic-require m #f)))"):format(mod)
  require("config.terminal").run({
    "racket",
    -- The REPL starts output on a fresh line before its prompt, but only knows
    -- the column once line counting is on; it turns that on itself too late
    -- for the -e output, so a bare `(printf "hi")` got drawn over.
    "-e", "(port-count-lines! (current-output-port))",
    "-e", ("(enter! %s)"):format(mod),
    "-e", run_subs,
    "-i",
  }, vim.fn.expand("%:p:h"))
end, { buffer = true, desc = "Run Racket file in REPL" })

-- $VIMRUNTIME/ftplugin/racket.vim maps K to `raco docs` (opens a browser),
-- and Neovim only adds its LSP hover K when K is unmapped. Drop the runtime one
-- so K is hover here too, like every other language.
pcall(vim.keymap.del, { "n", "x" }, "K", { buffer = true })
