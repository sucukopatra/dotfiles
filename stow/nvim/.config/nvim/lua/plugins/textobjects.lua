-- Treesitter textobjects (main branch). Like nvim-treesitter itself, the main
-- branch dropped the declarative `textobjects = { select = { keymaps = ... } }`
-- table in favour of explicit keymaps, and does not support lazy-loading.
local select_objects = {
  ["af"] = "@function.outer",
  ["if"] = "@function.inner",
  ["ac"] = "@class.outer",
  ["ic"] = "@class.inner",
  ["aa"] = "@parameter.outer",
  ["ia"] = "@parameter.inner",
}

-- Deliberately not mapping ]c/[c: those are Vim's diff-mode change motions and
-- are wanted intact inside Diffview.
local move_objects = {
  goto_next_start = { ["]f"] = "@function.outer", ["]a"] = "@parameter.inner" },
  goto_next_end = { ["]F"] = "@function.outer" },
  goto_previous_start = { ["[f"] = "@function.outer", ["[a"] = "@parameter.inner" },
  goto_previous_end = { ["[F"] = "@function.outer" },
}

return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  lazy = false,
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  -- The README suggests `vim.g.no_plugin_maps = true` here. It is not read by
  -- this plugin at all; it is a Vim runtime variable that strips ]]/[[/]m/[m
  -- from the built-in python and gdscript ftplugins. The maps below avoid those
  -- lhs's anyway, so there is nothing to opt out of.
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    for lhs, obj in pairs(select_objects) do
      vim.keymap.set({ "x", "o" }, lhs, function()
        select.select_textobject(obj, "textobjects")
      end, { desc = "Select " .. obj })
    end

    local move = require("nvim-treesitter-textobjects.move")
    for fn, maps in pairs(move_objects) do
      for lhs, obj in pairs(maps) do
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          move[fn](obj, "textobjects")
        end, { desc = fn:gsub("_", " ") .. " " .. obj })
      end
    end
  end,
}
