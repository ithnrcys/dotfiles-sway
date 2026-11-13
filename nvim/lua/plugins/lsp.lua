-- Language intelligence: language servers (installed by Mason), completion, formatting.
local servers = {
  "lua_ls",                      -- Lua (this config)
  "basedpyright", "ruff",        -- Python: types / completion, lint
  "ts_ls", "html", "cssls", "jsonls", -- web
  "clangd", "rust_analyzer",     -- C / C++, Rust
  "bashls", "yamlls", "taplo", "marksman", -- shell, YAML, TOML, Markdown
}
local tools = { "stylua", "prettier", "shfmt", "shellcheck" } -- formatters and linters

return {
  { "mason-org/mason.nvim", cmd = { "Mason", "MasonInstall", "MasonUpdate" }, opts = { ui = { border = "rounded" } } },
  {
    "mason-org/mason-lspconfig.nvim", -- installs the servers above and enables each one automatically
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = { ensure_installed = servers },
    config = function(_, opts)
      vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
      vim.diagnostic.config({ virtual_text = { spacing = 2, prefix = "●" }, severity_sort = true, float = { border = "rounded" } })
      require("mason-lspconfig").setup(opts)

      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Shortcuts that only make sense once a language server is attached",
        callback = function(ev)
          local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc }) end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", "<cmd>FzfLua lsp_references<cr>", "References")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          -- K (hover docs) is built in
        end,
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = { ensure_installed = tools },
  },
  {
    "saghen/blink.cmp", -- completion popup: Tab accepts, Ctrl-n / Ctrl-p or arrows move, Ctrl-space opens
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "super-tab" },
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },
  {
    "stevearc/conform.nvim", -- formatting; runs on save, and on <leader>cf
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = { { "<leader>cf", function() require("conform").format({ async = true }) end, desc = "Format file" } },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        javascript = { "prettier" }, typescript = { "prettier" },
        javascriptreact = { "prettier" }, typescriptreact = { "prettier" },
        html = { "prettier" }, css = { "prettier" }, json = { "prettier" },
        yaml = { "prettier" }, markdown = { "prettier" },
        sh = { "shfmt" }, bash = { "shfmt" },
        -- C / C++ (clang-format), Rust (rustfmt) and TOML (taplo) format through their language server
      },
      format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
    },
  },
}
