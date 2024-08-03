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
        ./pkgs/installer/sd-card/sd-image.nix
        "${inputs.nixpkgs}/nixos/modules/profiles/base.nix"
        "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
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
      boot.kernelPackages = pkgs.linuxPackages_6_9;

      # opi needs the uboot image written to a specific part of the firmware.
      # sdImage.postBuildCommands = ''dd if=${pkgs.ubootOrangePiZero3}/u-boot-sunxi-with-spl.bin of=$img bs=8 seek=1024 conv=notrunc'';

      sdImage = {
        firmwarePartitionOffset = 1;
        firmwareSize = 200;
        firmwarePartitionName = "BOOT";
        postBuildCommands = let
          bootloaderFilename = "u-boot-sunxi-with-spl.bin";
          bootloaderPackage =
            pkgs.buildUBoot
            {
              defconfig = "orangepi_zero2w_defconfig";
              extraMeta.platforms = ["aarch64-linux"];
              BL31 = "${pkgs.armTrustedFirmwareAllwinnerH616}/bl31.bin";
              SCP = "/dev/null";
              filesToInstall = [bootloaderFilename];
            };
        in ''
          echo "Flashing u-boot: ${bootloaderPackage}/${bootloaderFilename}"
          dd if=${bootloaderPackage}/${bootloaderFilename} of=$img bs=1k seek=8 conv=notrunc,fsync status=progress
          fdisk -l $img
        '';
        populateFirmwareCommands = ''
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
        '';
        populateRootCommands = ''
          mkdir -p ./files/boot
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
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
