{
  linuxManualConfig,
  lib,
  stdenv,
  ubootTools,
  fetchurl,
  ...
}:
(linuxManualConfig rec {
  inherit lib stdenv;
  version = "6.6.16";
  modDirVersion = "6.6.16-MANJARO-ARM";

  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
    hash = "sha256-sh1XlaO+rU8RKRZCMiL6qKD1GeQgHfND4+uI3J5KqjA";
  };

  # src = fetchGit {
  #   url = "https://github.com/orangepi-xunlong/linux-orangepi.git";
  #   rev = "71144529b0334d1488624c41d0d3ba0cb03dd4c1";
  #   ref = "orange-pi-6.1-sun50iw9";
  # };
  # existing makefiles for the uwe5622 driver configure themselves nondeterministically.
  # these patches remove the usage of shell calls and instead use the nix store path.
  kernelPatches = [
    {
      name = "arm64-dts-allwinner-add-hdmi-sound-to-pine-devices";
      patch = ./1001-arm64-dts-allwinner-add-hdmi-sound-to-pine-devices.patch;
    }
    {
      name = "arm64-dts-allwinner-add-ohci-ehci-to-h5-nanopi";
      patch = ./1002-arm64-dts-allwinner-add-ohci-ehci-to-h5-nanopi.patch;
    }
    {
      name = "drm-bridge-analogix_dp-Add-enable_psr-param";
      patch = ./1003-drm-bridge-analogix_dp-Add-enable_psr-param.patch;
    }
    {
      name = "panfrost-Silence-Panfrost-gem-shrinker-loggin";
      patch = ./1005-panfrost-Silence-Panfrost-gem-shrinker-loggin.patch;
    }
    {
      name = "arm64-dts-rockchip-Add-Firefly-Station-p1-support";
      patch = ./1006-arm64-dts-rockchip-Add-Firefly-Station-p1-support.patch;
    }
    {
      name = "arm64-dts-rockchip-Add-PCIe-bus-scan-delay-to-RockPr";
      patch = ./1012-arm64-dts-rockchip-Add-PCIe-bus-scan-delay-to-RockPr.patch;
    }
    {
      name = "arm64-dts-rockchip-Add-PCIe-bus-scan-delay-to-Rock-P";
      patch = ./1015-arm64-dts-rockchip-Add-PCIe-bus-scan-delay-to-Rock-P.patch;
    }
    {
      name = "ASOC-sun9i-hdmi-audio-Initial-implementation";
      patch = ./1016-ASOC-sun9i-hdmi-audio-Initial-implementation.patch;
    }
    {
      name = "arm64-dts-allwinner-h6-Add-hdmi-sound-card";
      patch = ./1017-arm64-dts-allwinner-h6-Add-hdmi-sound-card.patch;
    }
    {
      name = "arm64-dts-allwinner-h6-Enable-hdmi-sound-card-on-boards";
      patch = ./1018-arm64-dts-allwinner-h6-Enable-hdmi-sound-card-on-boards.patch;
    }
    {
      name = "arm64-dts-allwinner-add-OrangePi-3-LTS";
      patch = ./1019-arm64-dts-allwinner-add-OrangePi-3-LTS.patch;
    }
    {
      name = "arm64-dts-rockchip-add-OrangePi-4-LTS";
      patch = ./1024-arm64-dts-rockchip-add-OrangePi-4-LTS.patch;
    }
    {
      name = "net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regu";
      patch = ./3044-net-stmmac-sun8i-Use-devm_regulator_get-for-PHY-regu.patch;
    }
    {
      name = "net-stmmac-sun8i-Rename-PHY-regulator-variable-to-re";
      patch = ./3045-net-stmmac-sun8i-Rename-PHY-regulator-variable-to-re.patch;
    }
    {
      name = "net-stmmac-sun8i-Add-support-for-enabling-a-regulato";
      patch = ./3046-net-stmmac-sun8i-Add-support-for-enabling-a-regulato.patch;
    }
    {
      name = "linux-0002-rockchip-from-list";
      patch = ./4000-linux-0002-rockchip-from-list.patch;
    }
    {
      name = "linux-0011-v4l2-from-list";
      patch = ./4001-linux-0011-v4l2-from-list.patch;
    }
    {
      name = "linux-0020-drm-from-list";
      patch = ./4002-linux-0020-drm-from-list.patch;
    }
    {
      name = "linux-1000-drm-rockchip";
      patch = ./4003-linux-1000-drm-rockchip.patch;
    }
    {
      name = "linux-1001-v4l2-rockchip";
      patch = ./4004-linux-1001-v4l2-rockchip.patch;
    }
    {
      name = "linux-1002-for-libreelec";
      patch = ./4005-linux-1002-for-libreelec.patch;
    }
    {
      name = "linux-1003-temp-dw_hdmi-rockchip";
      patch = ./4006-linux-1003-temp-dw_hdmi-rockchip.patch;
    }
    {
      name = "linux-2000-v4l2-wip-rkvdec-hevc";
      patch = ./4006-linux-2000-v4l2-wip-rkvdec-hevc.patch;
    }
    {
      name = "linux-2001-v4l2-wip-iep-driver";
      patch = ./4007-linux-2001-v4l2-wip-iep-driver.patch;
    }
    {
      name = "clk-rk3399-Add-sclk-i2sout-src-clock";
      patch = ./4006-clk-rk3399-Add-sclk-i2sout-src-clock.patch;
    }
    {
      name = "drm-rockchip-analogix_dp-Accept-drm_of_find_panel_or";
      patch = ./4007-drm-rockchip-analogix_dp-Accept-drm_of_find_panel_or.patch;
    }
    {
      name = "drm-rockchip-analogix_dp-Fix-AUX-CH-enable-timeout";
      patch = ./4008-drm-rockchip-analogix_dp-Fix-AUX-CH-enable-timeout.patch;
    }
    {
      name = "drm-bridge-analogix_dp-Fix-hpd-handling";
      patch = ./4009-drm-bridge-analogix_dp-Fix-hpd-handling.patch;
    }
    {
      name = "clk-rockchip-Update-pll-setting";
      patch = ./4014-clk-rockchip-Update-pll-setting.patch;
    }
    {
      name = "staging-Add-fusb30x-driver";
      patch = ./4015-staging-Add-fusb30x-driver.patch;
    }
    {
      name = "arm64-dts-rockchip-Add-Orange-Pi-800-dts";
      patch = ./4020-arm64-dts-rockchip-Add-Orange-Pi-800-dts.patch;
    }
    {
      name = "arm64-dts-rockchip-enable-i2c2-i2c4-uart4";
      patch = ./4022-arm64-dts-rockchip-enable-i2c2-i2c4-uart4.patch;
    }
    {
      name = "5001";
      patch = ./5001.patch;
    }
    {
      name = "sid";
      patch = ./5002-sid.patch;
    }
    {
      name = "dma";
      patch = ./5003-dma.patch;
    }
    {
      name = "thermal";
      patch = ./5004-thermal.patch;
    }
    {
      name = "cpufreq";
      patch = ./5005-cpufreq.patch;
    }
    {
      name = "gpu";
      patch = ./5006-gpu.patch;
    }
    # {
    #   name = "net-wireless-add-uwe5622-support-v20231020";
    #   patch = ./5001-net-wireless-add-uwe5622-support-v20231020.patch;
    # }
    {
      name = "hdmi";
      patch = ./5008-hdmi.patch;
    }
    {
      name = "add-hdmi-to-opi-zero";
      patch = ./5009-add-hdmi-to-opi-zero.patch;
    }
    {
      name = "gpu-opp";
      patch = ./5010-gpu-opp.patch;
    }
    {
      name = "5014";
      patch = ./5014.patch;
    }
    {
      name = "hdmi2";
      patch = ./5015-hdmi2.patch;
    }
  ];

  # enables several nixos-specific kernel features and properly enables wifi driver modules.
  configfile = ./config;
  allowImportFromDerivation = true;
})
.overrideAttrs (old: {
  name = "k"; # dodge uboot length limits
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
