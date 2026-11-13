-- Look: theme, status line, icons, key hints, indent guides.
return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000, -- load before everything else so nothing flashes unthemed
    config = function()
      require("kanagawa").setup({
        compile = false,
        theme = "wave",        -- wave (default) | dragon (darker, warmer) | lotus (light)
        dimInactive = false,
        colors = { theme = { all = { ui = { bg_gutter = "none" } } } }, -- no separate strip behind line numbers
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "auto", globalstatus = true, section_separators = "", component_separators = "│" },
      sections = {
        lualine_c = { { "filename", path = 1 } }, -- path relative to the project
        lualine_x = { "diagnostics", "filetype" },
      },
    },
  },
  { "folke/which-key.nvim", event = "VeryLazy", opts = { preset = "modern" } }, -- popup listing shortcuts
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = "BufReadPost", opts = { scope = { enabled = false } } },
}
