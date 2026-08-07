return {
  {
    "nyoom-engineering/oxocarbon.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("oxocarbon")

      -- UI
      vim.api.nvim_set_hl(0, "Normal", { bg = "#0d0d0f" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#0d0d0f" })

      vim.api.nvim_set_hl(0, "CursorLine", {
        bg = "#1a1a1f",
      })

      vim.api.nvim_set_hl(0, "Visual", {
        bg = "#392534",
      })

      vim.api.nvim_set_hl(0, "Search", {
        fg = "#ffffff",
        bg = "#f5a9c5",
      })

      -- Syntax
      vim.api.nvim_set_hl(0, "Comment", {
        fg = "#6d6d7a",
        italic = true,
      })

      vim.api.nvim_set_hl(0, "Keyword", {
        fg = "#f5a9c5",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "Type", {
        fg = "#cba6f7",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "Function", {
        fg = "#ffb7d5",
      })

      vim.api.nvim_set_hl(0, "String", {
        fg = "#e88ab5",
      })

      vim.api.nvim_set_hl(0, "Number", {
        fg = "#f9c784",
      })

      -- Treesitter
      vim.api.nvim_set_hl(0, "@variable", {
        fg = "#f2d5e5",
      })

      vim.api.nvim_set_hl(0, "@parameter", {
        fg = "#ffb7d5",
        italic = true,
      })

      vim.api.nvim_set_hl(0, "@property", {
        fg = "#f5a9c5",
      })

      vim.api.nvim_set_hl(0, "@constant", {
        fg = "#f5a9c5",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "@function", {
        fg = "#ffb7d5",
      })

      vim.api.nvim_set_hl(0, "@function.call", {
        fg = "#ffd3e4",
      })

      vim.api.nvim_set_hl(0, "@keyword", {
        fg = "#f5a9c5",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "@string", {
        fg = "#e88ab5",
      })

      vim.api.nvim_set_hl(0, "@number", {
        fg = "#f9c784",
      })

      vim.api.nvim_set_hl(0, "@type", {
        fg = "#cba6f7",
        bold = true,
      })
    end,
  },
}
