return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    opts.formatters.c_formatter_42 = {
      command = "c_formatter_42",
      args = { "$FILENAME" },
      stdin = false,
    }

    opts.formatters_by_ft.c = { "c_formatter_42" }
  end,
}
