return {
  cmd = { "harper-ls", "--stdio" },
  filetypes = { "markdown", "typst", "gitcommit" },
  root_markers = { ".git" },
  settings = {
    ["harper-ls"] = {
      linters = {
        SpellCheck = false,
      },
    },
  },
}
