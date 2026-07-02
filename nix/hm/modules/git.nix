{
  programs.git = {
    enable = true;

    settings = {
      user.name = "busybox11";
      user.email = "29630035+busybox11@users.noreply.github.com";
    };

    includes = [
      { path = "~/.gitconfig.local"; }
    ];
  };
}
