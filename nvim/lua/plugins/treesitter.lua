-- Syntax highlighting and indentation from real parsers (tree-sitter).
local languages = {
  "bash", "c", "cpp", "css", "diff", "git_config", "gitcommit", "gitignore", "html", "ini",
  "javascript", "jsdoc", "json", "lua", "luadoc", "make", "markdown", "markdown_inline",
  "python", "query", "regex", "rust", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- the rewrite for current Neovim; parsers are compiled with gcc + the tree-sitter CLI
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(languages)
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Start tree-sitter highlighting and indentation where a parser exists",
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
