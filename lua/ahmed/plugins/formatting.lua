return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>mp",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "Format file or range (in visual mode)",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      json = { "prettier" },
      markdown = { "prettier" },
      yaml = { "yamlfmt" },
    },
    format_on_save = {
      lsp_format = "fallback",
      timeout_ms = 1000,
    },
  },
}
