# Pin UWSM background slices to the Zen 5c cores for battery efficiency.
machine: {
  # Delegate cpuset to the user manager so AllowedCPUs can pin UWSM
  # background slices to the Zen 5c cores (see home-manager below).
  systemd.services."user@" = {
    overrideStrategy = "asDropin";
    serviceConfig.Delegate = "cpu cpuset io memory pids";
  };

  # Pin UWSM background slices to the 8 Zen 5c cores (Ryzen AI 9 HX 370:
  # cores 8-15 -> logical CPUs 4-11 and 16-23; Zen 5 fast cores are 0-3,12-15).
  # Drop-ins rather than full units so UWSM's slice definitions stay intact.
  # Requires the user@.service cpuset delegation above.
  home-manager.users.${machine.username}.home.file = {
    ".config/systemd/user/background.slice.d/override.conf".text = ''
      [Slice]
      AllowedCPUs=4-11 16-23
    '';
    ".config/systemd/user/background-graphical.slice.d/override.conf".text = ''
      [Slice]
      AllowedCPUs=4-11 16-23
    '';
  };
}