return {
  "MoulatiMehdi/42header.nvim",
  lazy = false,

  config = function()
    vim.g.user42 = "raaribou"
    vim.g.mail42 = "raaribou@student.1337.ma"

    require("42header")
  end,
}
