{ config, ... }:

{
  imports = [ ./common.nix ];

  xdg.configFile."git/taillight.local.gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/config/git/taillight.local.gitconfig";

  programs.git.includes = [
    {
      condition = "gitdir:~/code/taillight/";
      path = "${config.xdg.configHome}/git/taillight.local.gitconfig";
    }
  ];
}
