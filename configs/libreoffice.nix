{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.libreoffice-bin
  ];
}
