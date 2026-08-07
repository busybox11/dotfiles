{
  lovefield = {
    ethernet = {
      ipv4 = "192.168.1.20";
      prefixLength = 24;
    };
    wifi = {
      ipv4 = "192.168.1.21";
      prefixLength = 24;
    };
  };
  chaeri = {
    ethernet = builtins.throw "voidroid eth IP not set yet";
    wifi = builtins.throw "voidroid wifi IP not set yet";
  };
  voidroid = {
    ethernet = builtins.throw "voidroid eth IP not set yet";
    wifi = builtins.throw "voidroid wifi IP not set yet";
  };
  bitcrusher = {
    ethernet = builtins.throw "voidroid eth IP not set yet";
    wifi = builtins.throw "voidroid wifi IP not set yet";
  };
  # Arch-host migration VM — not deploy-rs target.
  devvm = {
    deploy = false;
    ethernet = {
      ipv4 = "127.0.0.1";
      prefixLength = 24;
    };
    wifi = {
      ipv4 = "127.0.0.1";
      prefixLength = 24;
    };
  };
}
