return {
  "nvim-mini/mini.ai",
  event = "VeryLazy",
  opts = function()
    return {
      custom_textobjects = {
        F = require("mini.ai").gen_spec.function_call(),
      },
    }
  end,
}
