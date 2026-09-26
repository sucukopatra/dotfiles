-- Not in Mason: installed into Racket itself with
-- `raco pkg install --auto racket-langserver`.
return {
  cmd = { "racket", "--lib", "racket-langserver" },
  filetypes = { "racket" },
  root_markers = { ".git", "info.rkt" },
}
