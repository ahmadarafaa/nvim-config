return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame = true,
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", gitsigns.next_hunk, "Next git hunk")
      map("n", "[h", gitsigns.prev_hunk, "Previous git hunk")

      map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
      map("v", "<leader>hs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
      map("v", "<leader>hr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")
      map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>hB", gitsigns.toggle_current_line_blame, "Toggle current line blame")
      map("n", "<leader>hd", gitsigns.diffthis, "Diff this")
      map("n", "<leader>hD", function()
        gitsigns.diffthis("~")
      end, "Diff this (against ~)")

      map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
    end,
  },
}
