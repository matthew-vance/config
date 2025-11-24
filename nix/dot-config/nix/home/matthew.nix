{ config, pkgs, ... }:

{
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      commit.gpgsign = true;
      core.pager = "delta --line-numbers";
      delta = {
        hyperlinks = true;
        interactive.keep-plus-minus-markers = false;
      };
      diff.colorMoved = "default";
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      init.defaultBranch = "main";
      interactive.diffFilter = "delta --color-only --features=interactive";
      merge.conflictStyle = "diff3";
      pull.rebase = "false";
      push.autoSetupRemote = true;
      user = {
        name = "Matthew Vance";
        email = "mavance44@gmail.com";
      };
    };
    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/G8WN10/FlsokXrjIJ2C7Ev70Q8OL66dSfRXmP94hU";
    };
  };
}
