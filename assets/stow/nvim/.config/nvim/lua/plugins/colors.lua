local function enable_transparency()
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#ffffff", bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#888888", bg = "NONE" })

end

-- lua/plugins/rose-pine.lua
return {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            vim.cmd("colorscheme rose-pine")
            enable_transparency()
            -- Transparent background for Telescope
            vim.api.nvim_set_hl(0, "TelescopeNormal",      { bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeBorder",      { bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptNormal",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptBorder",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsNormal",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsTitle",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopeResultsBorder",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewNormal",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewTitle",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "TelescopePreviewBorder",{ bg = "NONE" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
        end
}
