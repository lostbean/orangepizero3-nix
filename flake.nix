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
      linux-overlay = import ./pkgs/linux-patched;
    in {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
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
        linux-overlay
      ];

      # u-boot, no grub, no efi.
      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;
      boot.loader.efi.canTouchEfiVariables = false;

      # slim supported filesystems.
      boot.supportedFilesystems = pkgs.lib.mkForce ["vfat" "ext4"];
      boot.initrd.supportedFilesystems = pkgs.lib.mkForce ["vfat" "ext4"];

      # your shiny custom kernel.
      boot.kernelPackages = let
        kernel = pkgs.callPackage ./pkgs/linux {};
      in
        # pkgs.linuxPackages_sun50i;
        # pkgs.linuxPackages_6_9;
        pkgs.linuxPackagesFor kernel;

      sdImage = {
        firmwarePartitionOffset = 1;
        firmwareSize = 200;
        firmwarePartitionName = "BOOT";
        postBuildCommands = let
          bootloaderFilename = "u-boot-sunxi-with-spl.bin";
          bootloaderPackage = pkgs.callPackage ./pkgs/uboot {};
          # mainline u-boot still doesn't support the zero 2w
          bootloaderPackageMainline =
            pkgs.pkgsCross.aarch64-multiplatform.buildUBoot
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
        '';
        populateFirmwareCommands = "";
        populateRootCommands = ''
          mkdir -p ./files/boot
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
        '';
      };

      # this gets burned straight onto an sd. no point in zstd.
      sdImage.compressImage = false;

      users = {
        mutableUsers = false;
        users.admin = {
          isNormalUser = true;
          password = "admin";
          extraGroups = ["wheel"];
        };
      };

      networking = {
        hostName = "zero2w";
        wireless = {
          enable = true;
          networks."Rimac Nevera".psk = "array9leap2recall";
          interfaces = ["wan0" "wlan0"];
        };
      };

      hardware.firmware = let
        wifi =
          pkgs.callPackage
          ./pkgs/firmware
          {};
      in [
        wifi
      ];

      environment.systemPackages = with pkgs; [vim];
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
