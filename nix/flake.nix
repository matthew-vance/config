{
  description = "Matthew's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            antidote
            bat
            curl
            delta
            eza
            fd
            fnm
            fzf
            git
            git-lfs
            go
            httpie
            lazydocker
            lua
            jq
            kubectl
            lazygit
            neovim
            nixfmt
            ripgrep
            starship
            terraform
            unixtools.watch
            unzip
            watchman
            wget
            xh
            yazi
            zoxide
            zsh
          ];

          environment.shells = [ pkgs.zsh ];

          fonts.packages = with pkgs; [
            jetbrains-mono
            nerd-fonts.jetbrains-mono
          ];

          nix = {
            optimise.automatic = true;
            gc = {
              automatic = true;
              options = "--delete-older-than 30d";
            };
          };

          homebrew = {
            enable = true;
            brews = [
              "mas"
            ];
            casks = [
              "1password"
              "1password-cli"
              "chatgpt"
              "cleanshot"
              "docker-desktop"
              "firefox"
              "ghostty"
              "google-chrome"
              "hyperkey"
              "jetbrains-toolbox"
              "maccy"
              "obsidian"
              "raycast"
              "slack"
              "visual-studio-code"
            ];
            masApps = {
              Drafts = 1435957248;
              Dropover = 1355679052;
              Xcode = 497799835;
            };
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;
          programs.zsh.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          nixpkgs.config = {
            allowUnfree = true;
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Matthews-MacBook-Pro
      darwinConfigurations."Matthews-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          configuration
          ./hosts/Matthews-MacBook-Pro.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.matthewvance = ./home/matthewvance.nix;
            };
          }
        ];
      };
    };
}
