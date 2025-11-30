{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fastfetch
    opentofu
  ];

  environment.pathsToLink = [
    "/share/zsh"
  ];

  homebrew = {
    user = "matthewvance";
    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      upgrade = true;
      autoUpdate = true;
    };
    brews = [ "brogue" ];
    casks = [
      "affinity"
      "discord"
      "cryptomator"
      "daisydisk"
      "godot"
      "iina"
      "mullvad-vpn"
    ];
  };

  users.users."matthewvance" = {
    name = "matthewvance";
    home = "/Users/matthewvance";
    shell = pkgs.zsh;
  };
}
