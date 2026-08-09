{
  pkgs,
  dotfilesPath,
  lib,
  ...
}:
{
  programs.ssh = {
    enable = true;

    settings."github.com" = {
      HostName = "github.com";
      User = "git";
      IdentityFile = "~/.ssh/id_ed25519";
      IdentitiesOnly = true;
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user.name = "busybox11";
      user.email = "29630035+busybox11@users.noreply.github.com";
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
    };

    includes = [
      { path = "~/.gitconfig.local"; }
      {
        condition = "gitdir:${dotfilesPath}/";
        contents.core.hooksPath = "githooks";
      }
    ];
  };

  home.packages = [ pkgs.git-crypt ];
}
