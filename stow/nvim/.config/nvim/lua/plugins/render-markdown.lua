return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  opts = {
    -- Leaving render_modes at its default ({ "n", "c", "t" }) keeps the raw
    -- source visible in insert mode, which is when it matters.
    file_types = { "markdown" },
  },
}
