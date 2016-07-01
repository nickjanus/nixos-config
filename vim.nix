with import <nixpkgs> {};

pkgs.neovim.override {
  vimAlias = true;
  configure = {
    customRC = ''
      syntax enable

      """ My settings:
      " tab with two spaces
      set nobackup
      set noswapfile
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set expandtab
      set smartcase
      set autoindent
      set nostartofline
      set hlsearch      " highlight search terms
      set incsearch     " show search matches as you type

      set mouse=a
      set cmdheight=2

      set wildmenu
      set showcmd

      set number
      set ruler
      set backspace=indent,eol,start " Allows backspace on these character
      set clipboard+=unnamedplus " Allows copy and paste from nvim
      set pastetoggle=<F2> " Press F2 to enter paste mode, for pasting from outside vim

      " php
      autocmd Filetype php setlocal tabstop=4 shiftwidth=4 softtabstop=4

      " ruby
      autocmd FileType ruby compiler ruby
      filetype plugin on    " Enable filetype-specific plugins

      " Those types
      if has("user_commands")
        command! -bang -nargs=? -complete=file E e<bang> <args>
        command! -bang -nargs=? -complete=file W w<bang> <args>
        command! -bang -nargs=? -complete=file Wq wq<bang> <args>
        command! -bang -nargs=? -complete=file WQ wq<bang> <args>
        command! -bang Wa wa<bang>
        command! -bang WA wa<bang>
        command! -bang Q q<bang>
        command! -bang QA qa<bang>
        command! -bang Qa qa<bang>
      endif

      " Relative numbering
      function! NumberToggle()
        if(&relativenumber == 1)
          set nornu
          set number
        else
          set rnu
        endif
      endfunc

      " Toggle between normal and relative numbering.
      nnoremap <leader>r :call NumberToggle()<cr>

      " airline settings
      let g:airline_theme = 'solarized dark'
      let g:airline_powerline_fonts = 1

      " gitgutter settings
      let g:gitgutter_max_signs = 2000

      " vim-multiple-cursors settings
      nnoremap <silent> <M-j> :MultipleCursorsFind <C-R>/<CR>
      vnoremap <silent> <M-j> :MultipleCursorsFind <C-R>/<CR>
    '';

    vam.knownPlugins = pkgs.vimPlugins; # optional
    vam.pluginDictionaries = [
      # load always
      {
        # todo: Add the commented out plugins as packages
        names = [
          "airline"
          "ctrlp"
          "fugitive"
          "surround"
          "Solarized"
          "multiple-cursors"
          "syntastic"
          # "camelcasemotion"
          "gitgutter"
          # "github:elixir-lang/vim-elixir"
          # "github:vim-ruby/vim-ruby"
          # "github:ajf/puppet-vim"
          # "github:elzr/vim-json"
          "vim-nix"
          #"vim2nix"
          #"pluginnames2nix"
        ];
      }
    ];
  };
}
