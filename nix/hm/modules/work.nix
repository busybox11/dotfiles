{ config, lib, ... }:

let
  workDir = "${config.home.homeDirectory}/work";
  workIdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_work";
  secrets = import ../../../secrets/secrets.nix;
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
    header = "Match host github.com exec \"pwd | grep -qE '^${workDir}(/|$$)'\"";
    User = "git";
    IdentityFile = "~/.ssh/id_ed25519_work";
    IdentitiesOnly = true;
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

        # Covers git -C ~/work/... when cwd is elsewhere.
        core.sshCommand = "ssh -i ${workIdentityFile} -o IdentitiesOnly=yes";
      };
    }
  ];
}
