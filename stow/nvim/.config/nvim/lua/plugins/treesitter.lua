local ensure_installed = {
  "bash",
  "c",
  "c_sharp",
  "cpp",
  "diff",
  "gdscript",
  "gitcommit",
  "godot_resource",
  "json",
  "lua",
  -- Injected by the `lua` parser's own injections.scm; without it, ---@ LuaCATS
  -- annotations fall back to plain comment highlighting.
  "luadoc",
  "markdown",
  "markdown_inline",
  -- Injected by the c, lua, python and bash queries to highlight format-string
  -- specifiers. All four of those parsers are installed here.
  "printf",
  "python",
  "query",
  "racket",
  "regex",
  "toml",
  "typst",
  "vim",
  "vimdoc",
  -- Unity regenerates a .csproj per assembly on every asset change, and those
  -- resolve to filetype `xml`. Without the parser they open with no highlighting
  -- at all -- the one gap here that is visible on an ordinary day.
  "xml",
  "yaml",
}

-- Parsers that ship no indents query, where nvim-treesitter's indentexpr would
-- only copy the previous line's indent. Racket keeps Vim's Lisp indenting
-- instead ('lisp' + 'lispwords', set by $VIMRUNTIME/indent/racket.vim).
local runtime_indent = { racket = true }

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- No-op for parsers that are already installed.
    require("nvim-treesitter").install(ensure_installed)

    local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

    -- Buffer-scoped setup. Neovim makes the buffer current before firing
    -- FileType, so this is always the right buffer.
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      desc = "Start treesitter highlighting and indenting",
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then
          return
        end
        -- language.add returns nil (rather than erroring) when no parser is
        -- installed; starting anyway would throw on every such buffer.
        local ok, added = pcall(vim.treesitter.language.add, lang)
        if not ok or not added then
          return
        end
        vim.treesitter.start(args.buf, lang)
        if not runtime_indent[lang] then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        vim.b[args.buf].ts_folds = true
      end,
    })

    -- Window-scoped setup, deliberately split out. 'foldexpr'/'foldmethod' are
    -- window options, and a buffer loaded before it is displayed (session
    -- restore, :bufload, a plugin reading a file) fires FileType while sitting
    -- in a temporary autocmd window -- so folds set there are thrown away with
    -- that window and the buffer shows up unfolded. BufWinEnter fires again
    -- when the buffer lands in a real window, which is the only point where a
    -- window option can stick.
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      desc = "Attach treesitter folding to the window showing the buffer",
      callback = function(args)
        if not vim.b[args.buf].ts_folds then
          return
        end
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
      end,
    })
  end,
}
