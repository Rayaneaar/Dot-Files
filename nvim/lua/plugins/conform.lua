return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        c_formatter_42 = {
          command = "c_formatter_42",
        },
      },

      formatters_by_ft = {
        c = { "c_formatter_42" },
        h = { "c_formatter_42" },
      },
    },
  },
}
