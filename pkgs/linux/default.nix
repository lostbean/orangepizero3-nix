{
  linuxManualConfig,
  lib,
  stdenv,
  ...
}: (linuxManualConfig {
  inherit lib stdenv;
  version = "6.1.31-sun50iw9";
  modDirVersion = "6.1.31";

  src = fetchGit {
    url = "https://github.com/orangepi-xunlong/linux-orangepi.git";
    rev = "71144529b0334d1488624c41d0d3ba0cb03dd4c1";
    ref = "orange-pi-6.1-sun50iw9";
  };
  # existing makefiles for the uwe5622 driver configure themselves nondeterministically.
  # these patches remove the usage of shell calls and instead use the nix store path.
  kernelPatches = [
    {
      name = "uwe5622-Makefile";
      patch = ./uwe5622-Makefile-remove-monkeying.patch;
    }
    {
      name = "uwe5622-unisocwcn-Makefile";
      patch = ./uwe5622-unisocwcn-Makefile-remove-monkeying.patch;
    }
    {
      name = "uwe5622-unisocwcn-wcn_boot";
      patch = ./uwe5622-unisocwcn-wcn_boot.c-remove-monkeying.patch;
    }
  ];

  # enables several nixos-specific kernel features and properly enables wifi driver modules.
  configfile = ./sun50iw9_defconfig;
  allowImportFromDerivation = true;
})
