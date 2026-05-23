return {
  "nvim-treesitter/nvim-treesitter",
  main = "nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "bash",
      "c_sharp",
      "gdscript",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "typst",
      "vim",
      "vimdoc",
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
