{ pkgs, programs, ... }: {
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-nix vim-lastplace ];
    extraConfig = ''
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

  };
}
