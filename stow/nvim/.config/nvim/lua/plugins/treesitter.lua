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
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "toml",
  "typst",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- No-op for parsers that are already installed.
    require("nvim-treesitter").install(ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
      desc = "Start treesitter highlighting, folding and indenting",
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
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
      end,
    })
  end,
}
