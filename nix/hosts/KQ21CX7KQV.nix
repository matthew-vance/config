{ pkgs, ... }:

{

  environment.pathsToLink = [
    "/share/zsh"
  ];

  homebrew = {
    user = "matthew.vance";
    global.brewfile = true;
    onActivation = {
      cleanup = "zap";
      upgrade = true;
      autoUpdate = true;
    };
    casks = [
      "mongodb-compass"
      "notion"
      "postman"
      "yubico-authenticator"
    ];
    masApps = {
      Dato = 1470584107;
    };
  };

  users.users."matthew.vance" = {
    name = "matthew.vance";
    home = "/Users/matthew.vance";
    shell = pkgs.zsh;
  };
}
