{ ... }:

{
  imports = [ ./common.nix ];

  programs = {
    zsh = {
      shellAliases = {
        love = "/Applications/love.app/Contents/MacOS/love";
      };
    };
  };
}
