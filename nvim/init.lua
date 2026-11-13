-- Neovim config: lazy.nvim plugin manager, Kanagawa theme, IDE-style setup.
-- Layout:  lua/options.lua  lua/keymaps.lua  lua/plugins/*.lua (one file per area)
-- Leader key is Space. Press Space and wait to see every shortcut (which-key).

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")

-- plugin manager: clones itself on first start, then installs everything in lua/plugins/
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { colorscheme = { "kanagawa" } },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})
