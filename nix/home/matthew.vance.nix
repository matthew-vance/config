{ config, lib, ... }:

{
  imports = [ ./common.nix ];

  xdg.configFile."git/taillight.local.gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/config/git/taillight.local.gitconfig";

  programs = {
    git.includes = [
      {
        condition = "gitdir:~/code/taillight/";
        path = "${config.xdg.configHome}/git/taillight.local.gitconfig";
      }
    ];

    lazygit = {
      settings = {
        git = {
          commitPrefix = [
            {
              pattern = "^\\w+\\/(\\w+-\\d+).*";
              replace = "[$1] ";
            }
          ];
        };
      };
    };

    zsh = {
      initContent = lib.mkOrder 1500 ''
        [[ -s "${config.home.homeDirectory}/.sdkman/bin/sdkman-init.sh" ]] && source "${config.home.homeDirectory}/.sdkman/bin/sdkman-init.sh"
      '';
    };
  };
}
