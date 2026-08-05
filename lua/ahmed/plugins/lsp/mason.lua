return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "yamlls", -- YAML (K8s manifests, Helm values, pipelines)
        "bashls", -- bash scripting
        "dockerls", -- Dockerfile
        "terraformls", -- Terraform/HCL
        "jsonls", -- JSON
        "lua_ls", -- Lua (for this config itself)
        "pyright", -- Python (Ansible, scripts)
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "yamlfmt", -- yaml formatter
        "shfmt", -- bash/sh formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "prettier", -- json/markdown formatter
        "shellcheck", -- bash linter
        "yamllint", -- yaml linter
        "hadolint", -- dockerfile linter
      },
    })
  end,
}
