{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fastfetch
    opentofu
  ];

  homebrew = {
    user = "matthewvance";
    onActivation.cleanup = "uninstall";
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
