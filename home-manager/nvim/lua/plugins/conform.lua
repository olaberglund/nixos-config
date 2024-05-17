return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      haskell = { "fourmolu", "my_stylish" },
      nix = { "my_nixfmt" },
    },

    formatters = {
      my_stylish = {
        command = "stylish-haskell",
      },
      my_nixfmt = {
        command = "nixfmt",
      },
    },
  },
}
