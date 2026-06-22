return {
  "nvim-treesitter/nvim-treesitter",
  main = "nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "bash",
      "gdscript",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "typst",
      "vim",
      "vimdoc",
--      "c_sharp",
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
