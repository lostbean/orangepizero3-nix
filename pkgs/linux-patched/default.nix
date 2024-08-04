final: prev: let
  pkgs = final;
  lib = pkgs.lib;
in {
  linux_5_15_embedded = pkgs.callPackage ./linux-5.15.nix {
    kernelPatches = with pkgs.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
  };
  linux_6_1_embedded = pkgs.callPackage ./linux-6.1.nix {
    kernelPatches = with pkgs.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
  };
  linux_6_2_embedded = pkgs.callPackage ./linux-6.2.nix {
    kernelPatches = with pkgs.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
  };
  linuxPackages_sun50i = (pkgs.callPackage ./sun50i {}).extend (final: prev: {
    zfs = prev.stdenv;
  });
  linuxPackages_rpi4 = (pkgs.callPackage ./raspberry-pi {}).extend (final: prev: {
    zfs = prev.stdenv;
  });
}
