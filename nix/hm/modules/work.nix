{ config, lib, ... }:

let
  workDir = "${config.home.homeDirectory}/work";
  workIdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_work";
  secrets = import ../../../secrets/secrets.nix;
  workMatchExec = "pwd | grep -qE '^${workDir}(/|$)'";
in
{
  home.activation.work-dir = {
    before = [ "linkGeneration" ];
    after = [ "writeBoundary" ];
    data = ''
      mkdir -p "${workDir}"
    '';
  };

  programs.ssh.settings.github-work = lib.hm.dag.entryBefore [ "github.com" ] {
    header = "Match host github.com exec \"${workMatchExec}\"";
    User = "git";
    HostName = "github.com";
    IdentityFile = "~/.ssh/id_ed25519_work";
    IdentitiesOnly = true;
    # ssh-agent should not be used for work git operations, otherwise it will use the wrong key
    IdentityAgent = "none";
  };

  programs.git.includes = [
    {
      condition = "gitdir:${workDir}/";
      contents = {
        user = {
          name = secrets.workGitUsername;
          email = secrets.workGitEmail;
          signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519_work_sign.pub";
        };

        commit.gpgSign = true;
        gpg.format = "ssh";

        core.sshCommand = "ssh -i ${workIdentityFile} -o IdentitiesOnly=yes -o IdentityAgent=none";
      };
    }
  ];
}
