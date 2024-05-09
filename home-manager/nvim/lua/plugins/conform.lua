return {
       "stevearc/conform.nvim",
       opts = {
          formatters_by_ft = { 
              haskell = { "fourmolu" , "stylish" },
              nix = { "nixfmt" },
          }, 

          formatters = {
                stylish = {
                    command = "stylish-haskell",
                },
                nixfmt = {
                    command = "nixfmt"
                }
          },
       },
}

