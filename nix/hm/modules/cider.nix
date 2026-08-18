{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cider-2
  ];
}
