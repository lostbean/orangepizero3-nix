{
  pkgs,
  buildUBoot,
}:
buildUBoot {
  version = "2024.01";
  modDirVersion = "2024.01";
  src = fetchGit {
    url = "https://github.com/orangepi-xunlong/u-boot-orangepi.git";
    ref = "v2024.01";
    rev = "a4d4b0e24e185e84dd02f06f53999a8effde86db";
  };

  BL31 = "${pkgs.armTrustedFirmwareAllwinnerH616}/bl31.bin";
  defconfig = "orangepi_zero2w_defconfig";
  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
  extraMeta.platforms = ["aarch64-linux"];
}
