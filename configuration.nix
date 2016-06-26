# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    { 
      name = "nixos"; 
      device = "/dev/VolGroup/nixos"; 
      preLVM = false; 
    }
  ];

  environment.variables = {
    EDITOR = "nvim";
  };
  
  networking.hostName = "nicknix";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    chromium
    git
    gnupg
    gnupg1compat
    htop
    i3
    imagemagick
    neovim
    nix-repl # repl for the nix language
    openssh
    screen
    terminator
    wget
    zsh
  ];

  nixpkgs.config = {
    allowUnfree = true;

    chromium = {
      jre = false;
      enableGoogleTalkPlugin = true;
      enablePepperFlash = true;
      enablePepperPDF = true;
    };

    packageOverrides = pkgs: rec {
      neovim = pkgs.neovim.override {
        vimAlias = true;
	configure = {
          customRC = ''
            set colorcolumn=100 
            
            " For vim-colors-solarized
            syntax enable
            set background=dark " or light
            colorscheme solarized
            
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
            set clipboard=unnamed " Allows copy and paste from iterm2
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
          '';
          vam.knownPlugins = pkgs.vimPlugins; # optional
          vam.pluginDictionaries = [
            # load always
            { 
	      # todo: Add the commented out plugins as packages
              names = [ 
                "surround"
                "Solarized"
                "vim-multiple-cursors"
                "fugitive"
                # "github:ctrlpvim/ctrlp.vim"
                # "ack"
                "Syntastic"
                # "camelcasemotion"
                # "numbers"
                "vim-gitgutter"
                # "github:elixir-lang/vim-elixir"
                # "github:tpope/vim-markdown"
                # "github:vim-ruby/vim-ruby"
                # "github:ajf/puppet-vim"
                # "github:elzr/vim-json"
              ];
            }
          ];
        };
      };
    };
  };

  # List services that you want to enable:
  programs = {
    ssh.forwardX11 = false;
    ssh.startAgent = true;
    zsh.enable = true;
  };

  services = {
    nixosManual.showManual = true;
    xserver = {
      videoDrivers = [ "nvidia" ];
      autorun = true;
      enable = true;
      exportConfiguration = true;
      layout = "us";
      windowManager.i3.enable = true;
      windowManager.default = "i3";
      displayManager.slim = {
        enable = true;
	defaultUser = "nick";
        theme = pkgs.fetchurl {
          url    = "https://github.com/nickjanus/nixos-slim-theme/archive/2.1.tar.gz";
          sha256 = "8b587bd6a3621b0f0bc2d653be4e2c1947ac2d64443935af32384bf1312841d7";
        };
      };
    };
  };


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nick = {
    home = "/home/nick";
    description = "Nick Janus";
    extraGroups = [ "wheel" "networkmanager" ];
    # openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... alice@foobar" ];
    isNormalUser = true;
    uid = 1000;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
}
