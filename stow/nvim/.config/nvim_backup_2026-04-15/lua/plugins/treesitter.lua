return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "bash",
      "c_sharp",
      "json",
      "lua",
      "typst",
      "vim",
      "vimdoc",
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
