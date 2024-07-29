{
  description = "linux kernel 6.1, u-boot 2021.07, and supporting firmware for the orange pi zero 3";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  } @ inputs: let
    opi-module = {
      modulePaths,
      config,
      pkgs,
      ...
    }: let
      opiPkgs = import ./pkgs {inherit pkgs;};
    in {
      imports = [
        # "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
        "${inputs.nixpkgs}/nixos/modules/profiles/base.nix"
      ];

      nixpkgs.hostPlatform = "aarch64-linux";

      # dodge "module <x> not found" error for socs.
      hardware.enableRedistributableFirmware = pkgs.lib.mkForce false;
      nixpkgs.overlays = [
        (final: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // {allowMissing = true;});
        })
      ];

      # u-boot, no grub, no efi.
      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;
      boot.loader.efi.canTouchEfiVariables = false;

      # slim supported filesystems.
      boot.supportedFilesystems = pkgs.lib.mkForce ["vfat" "ext4"];
      boot.initrd.supportedFilesystems = pkgs.lib.mkForce ["vfat" "ext4"];

      # your shiny custom kernel.
      # boot.kernelPackages = pkgs.linuxPackagesFor opiPkgs.linuxOrangePiZero3; # however you get the package here is up to you - overlay or directly from the flake.

      # opi needs the uboot image written to a specific part of the firmware.
      # sdImage.postBuildCommands = ''dd if=${pkgs.ubootOrangePiZero3}/u-boot-sunxi-with-spl.bin of=$img bs=8 seek=1024 conv=notrunc'';

      sdImage = {
        firmwareSize = 200;
        firmwarePartitionName = "BOOT";
        postBuildCommands = ''
          dd if=${opiPkgs.ubootOrangePiZero3}/u-boot-sunxi-with-spl.bin of=$img bs=8 seek=1024 conv=notrunc
        '';
        populateFirmwareCommands = ''
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
        '';
        populateRootCommands = ''
        '';
      };

      # this gets burned straight onto an sd. no point in zstd.
      sdImage.compressImage = false;
    };
  in {
    opi =
      (nixpkgs.lib.nixosSystem
        {
          system = "aarch64-linux";
          modules = [
            opi-module
          ];
        })
      .config
      .system
      .build
      .sdImage;
  };
}
