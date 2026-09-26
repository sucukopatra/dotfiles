return {
  cmd = { "bash-language-server", "start" },
  -- No zsh: the server parses with tree-sitter-bash and lints with ShellCheck,
  -- which refuses zsh, so zsh buffers got misparsed symbols and no linting.
  -- shfmt still formats zsh through conform: its zsh dialect is partial (no
  -- `for k v in` loops, for one) but covers ~/.zshrc.
  filetypes = { "sh", "bash" },
  root_markers = { ".git" },
}
