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
  voidroid = {
    ethernet = builtins.throw "voidroid eth IP not set yet";
    wifi = builtins.throw "voidroid wifi IP not set yet";
  };
}
