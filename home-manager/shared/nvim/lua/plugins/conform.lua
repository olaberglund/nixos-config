return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      haskell = { "fourmolu", "my_stylish" },
      nix = { "my_nixfmt" },
      cabal = { "my_cabal_fmt" },
    },

    formatters = {
      my_stylish = {
        command = "stylish-haskell",
      },
      my_nixfmt = {
        command = "nixfmt",
      },
      my_cabal_fmt = {
        command = "cabal-fmt",
      },
    },
  },
}
