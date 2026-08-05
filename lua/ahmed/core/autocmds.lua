local augroup = vim.api.nvim_create_augroup("K8sSchemaAutoInsert", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
  group = augroup,
  pattern = { "*/k8s/*.yaml", "*/k8s/*.yml", "*/kubernetes/*.yaml", "*/kubernetes/*.yml", "*/manifests/*.yaml", "*/manifests/*.yml" },
  callback = function()
    local schema_url = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.0-standalone-strict/all.json"
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "# yaml-language-server: $schema=" .. schema_url })
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
  end,
})
