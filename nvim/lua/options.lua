local o = vim.opt

o.number = true            -- line numbers, relative to the cursor line
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"       -- always keep the git / diagnostics column, so text does not jump
o.scrolloff = 8
o.wrap = false
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus" -- yank / paste use the system clipboard

o.expandtab = true         -- spaces, 4 wide by default (filetype plugins and formatters override)
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true

o.ignorecase = true        -- case-insensitive search unless the pattern has capitals
o.smartcase = true
o.inccommand = "split"     -- live preview of :s substitutions

o.splitright = true
o.splitbelow = true
o.undofile = true          -- undo history survives closing the file
o.updatetime = 250
o.timeoutlen = 400
o.showmode = false         -- the status line already shows the mode
o.fillchars = { eob = " " }
o.winborder = "rounded"    -- border on hover docs and other floating windows
