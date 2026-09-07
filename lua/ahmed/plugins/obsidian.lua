local vault_path = vim.fn.expand("~/Documents/notes")

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  event = {
    "BufReadPre " .. vault_path .. "/*.md",
    "BufNewFile " .. vault_path .. "/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      { name = "notes", path = vault_path },
    },

    -- render-markdown.nvim already handles all visual concealing/prettifying;
    -- keep obsidian.nvim purely for linking/navigation logic to avoid the two
    -- plugins fighting over the same extmarks.
    ui = { enable = false },

    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    daily_notes = {
      folder = "daily",
      date_format = "%Y-%m-%d",
    },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    require("cmp").setup.filetype("markdown", {
      sources = require("cmp").config.sources({
        { name = "obsidian" },
        { name = "obsidian_new" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>on", "<cmd>ObsidianNew<cr>", { desc = "Obsidian: new note" })
    keymap.set("n", "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", { desc = "Obsidian: quick switch" })
    keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian: search vault" })
    keymap.set("n", "<leader>ol", "<cmd>ObsidianFollowLink<cr>", { desc = "Obsidian: follow link" })
    keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<cr>", { desc = "Obsidian: backlinks" })
    keymap.set("n", "<leader>ot", "<cmd>ObsidianToggleCheckbox<cr>", { desc = "Obsidian: toggle checkbox" })
    keymap.set("n", "<leader>og", "<cmd>ObsidianToday<cr>", { desc = "Obsidian: today's daily note" })
  end,
}
