-- Moving around and editing: fuzzy finder, file tree, git signs, pairs, surround.
return {
  {
    "ibhagwan/fzf-lua", -- uses the fzf binary already on the system
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Search text in project" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Open buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help pages" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Symbols in file" },
      { "<leader><leader>", "<cmd>FzfLua files<cr>", desc = "Find files" },
    },
    opts = {},
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    cmd = "Neotree",
    keys = { { "<leader>n", "<cmd>Neotree toggle<cr>", desc = "File tree" } },
    opts = {
      filesystem = { follow_current_file = { enabled = true }, filtered_items = { hide_dotfiles = false } },
      window = { width = 32 },
    },
  },
  {
    "lewis6991/gitsigns.nvim", -- added / changed / removed markers in the sign column
    event = "BufReadPre",
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
        map("]h", function() gs.nav_hunk("next") end, "Next git change")
        map("[h", function() gs.nav_hunk("prev") end, "Previous git change")
        map("<leader>gp", gs.preview_hunk, "Preview git change")
        map("<leader>gr", gs.reset_hunk, "Undo git change")
        map("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },
  { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },    -- closes brackets and quotes
  { "echasnovski/mini.surround", event = "VeryLazy", opts = {} },    -- sa / sd / sr: add, delete, replace surroundings
  { "folke/todo-comments.nvim", event = "BufReadPost", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
}
