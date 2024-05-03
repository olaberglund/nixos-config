return {
       "stevearc/conform.nvim",
       opts = {
          formatters_by_ft = { 
              haskell = { "fourmolu" , "stylish" } 
          }, 

          formatters = {
                stylish = {
                    command = "stylish-haskell",
                }
          },
       },
}

