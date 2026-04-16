return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local map = vim.keymap.set
    map("n", "<leader>ha", function() harpoon:list():add() end,                          { desc = "Harpoon add" })
    map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
    map("n", "<A-1>",      function() harpoon:list():select(1) end,                      { desc = "Harpoon file 1" })
    map("n", "<A-2>",      function() harpoon:list():select(2) end,                      { desc = "Harpoon file 2" })
    map("n", "<A-3>",      function() harpoon:list():select(3) end,                      { desc = "Harpoon file 3" })
    map("n", "<A-4>",      function() harpoon:list():select(4) end,                      { desc = "Harpoon file 4" })
    map("n", "<C-p>",      function() harpoon:list():prev() end,                         { desc = "Harpoon prev" })
    map("n", "<C-n>",      function() harpoon:list():next() end,                         { desc = "Harpoon next" })
  end,
}
