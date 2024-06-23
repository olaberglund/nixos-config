{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      ((vim_configurable.override { }).customize {
        name = "vim";
        vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
          start = [ vim-nix vim-lastplace ];
          opt = [ ];
        };

        vimrcConfig.customRC = ''
          set expandtab
          set colorcolumn=80
          syntax on
          set shiftwidth=4
          set tabstop=4
          set autoindent
          set smartindent
          colorscheme habamax
          cmap w!! w !sudo tee > /dev/null %
          set backspace=indent,eol,start
        '';
      })
    ];

}

