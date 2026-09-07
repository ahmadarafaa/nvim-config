return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})

    -- Markdown-specific surrounds, scoped to markdown buffers only so they
    -- don't shadow nvim-surround's normal () {} [] "" aliases elsewhere.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        require("nvim-surround").buffer_setup({
          surrounds = {
            ["b"] = { add = { "**", "**" } }, -- bold
            ["i"] = { add = { "*", "*" } }, -- italic
            ["s"] = { add = { "~~", "~~" } }, -- strikethrough
            ["l"] = { -- [text](url)
              add = function()
                local link = require("nvim-surround.config").get_input("Link: ")
                return { { "[" }, { "](" .. link .. ")" } }
              end,
            },
          },
        })
      end,
    })
  end,
}
