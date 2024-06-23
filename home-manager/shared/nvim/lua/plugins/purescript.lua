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
    },
  },
}
}
