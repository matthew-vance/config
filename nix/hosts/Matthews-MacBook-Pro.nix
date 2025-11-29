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
    onActivation.cleanup = "zap";
    brews = [ "brogue" ];
    casks = [
      "affinity"
      "discord"
      "cryptomator"
      "daisydisk"
      "godot"
      "iina"
      "mullvad-vpn"
      "pearcleaner"
      "utm"
      "wifiman"
    ];
  };

  users.users."matthewvance" = {
    name = "matthewvance";
    home = "/Users/matthewvance";
    shell = pkgs.zsh;
  };
}
