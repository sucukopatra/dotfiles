-- sa (add), sd (delete), sr (replace), sf/sF (find), sh (highlight).
-- This shadows normal-mode `s` (substitute); `cl` does the same thing.
return {
  "nvim-mini/mini.surround",
  event = "VeryLazy",
  opts = {},
}
