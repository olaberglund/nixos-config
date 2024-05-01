return {
  -- Syntax highlighting
  { "purescript-contrib/purescript-vim" },

  -- LspConfig
  {
    "neovim/nvim-lspconfig",

    ---@class PluginLspOpts
    opts = {

      ---@type lspconfig.options
      servers = {
        -- purescriptls will be automatically installed with mason and loaded with lspconfig
        purescriptls = {
          settings = {
            purescript = {
              formatter = "purs-tidy",
            },
          },
      },
      setup = {
        purescriptls = function(_, opts)
          opts.root_dir = function(path)
            local util = require("lspconfig.util")
            if path:match("/.spago/") then
              return nil
            end
            return util.root_pattern("bower.json", "psc-package.json", "spago.dhall", "flake.nix", "shell.nix")(path)
          end
        end,
      },
    },
  },
}
}
