-- lazy.nvim's `keys` entries carry their own callbacks, so the mappings are
-- declared once here rather than repeated as bare lhs stubs plus a config body.
local keys = {
  {
    "<leader>ha",
    function()
      require("harpoon"):list():add()
    end,
    desc = "Harpoon add",
  },
  {
    "<leader>hh",
    function()
      local harpoon = require("harpoon")
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end,
    desc = "Harpoon menu",
  },
  {
    "<A-p>",
    function()
      require("harpoon"):list():prev()
    end,
    desc = "Harpoon prev",
  },
  {
    "<A-n>",
    function()
      require("harpoon"):list():next()
    end,
    desc = "Harpoon next",
  },
}

for i = 1, 4 do
  table.insert(keys, {
    "<A-" .. i .. ">",
    function()
      require("harpoon"):list():select(i)
    end,
    desc = "Harpoon file " .. i,
  })
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = keys,
  -- setup() is declared as Harpoon.setup(self, config), so it needs the colon
  -- call; lazy's default opts handling would pass opts as `self`.
  config = function()
    require("harpoon"):setup()
  end,
}
