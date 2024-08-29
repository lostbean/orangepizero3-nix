{pkgs, ...}:
pkgs.linux_6_9.override {
  argsOverride = {
    kernelPatches = [
      pkgs.linuxKernel.kernelPatches.bridge_stp_helper
      pkgs.linuxKernel.kernelPatches.request_key_helper
      pkgs.linuxKernel.kernelPatches.rust_1_77-6_9
      pkgs.linuxKernel.kernelPatches.rust_1_78

      {
        name = "uwe5622-allwinner";
        patch = ./wireless-uwe5622/uwe5622-allwinner.patch;
        extraConfig = ''
          CONFIG_AW_WIFI_DEVICE_UWE5622 y
          CONFIG_AW_BIND_VERIFY y
          CONFIG_WLAN_UWE5621 m
          CONFIG_WLAN_UWE5622 m
          CONFIG_SPRDWL_NG m
          CONFIG_UNISOC_WIFI_PS y
          CONFIG_TTY_OVERY_SDIO m
          CONFIG_USB_NET_RNDIS_WLAN m
          CONFIG_VIRT_WIFI m
          CONFIG_IEEE802154_DRIVERS m
          CONFIG_WWAN m
          CONFIG_WWAN_DEBUGFS y
          CONFIG_WWAN_HWSIM m
          CONFIG_MHI_WWAN_CTRL m
          CONFIG_MHI_WWAN_MBIM m
          CONFIG_NETDEVSIM m
          CONFIG_NET_FAILOVER m
        '';
      }
      {
        name = "uwe5622-allwinner-bugfix";
        patch = ./wireless-uwe5622/uwe5622-allwinner-bugfix.patch;
      }
      {
        name = "uwe5622-warnings";
        patch = ./wireless-uwe5622/uwe5622-warnings.patch;
      }
      {
        name = "net-wireless-add-config";
        patch = ./wireless-uwe5622/net-wireless-add-config.patch;
        extraConfig = ''
          CONFIG_SPARD_WLAN_SUPPORT y
        '';
      }
      {
        name = "uwe5622-fix-setting-mac-address-for-netdev";
        patch = ./wireless-uwe5622/uwe5622-fix-setting-mac-address-for-netdev.patch;
      }
      {
        name = "wireless-uwe5622-Fix-compilation-with-6.7-kernel";
        patch = ./wireless-uwe5622/wireless-uwe5622-Fix-compilation-with-6.7-kernel.patch;
      }
      {
        name = "wireless-uwe5622-reduce-system-load";
        patch = ./wireless-uwe5622/wireless-uwe5622-reduce-system-load.patch;
      }
      # {
      #   name = "uwe5622-v6.9";
      #   patch = ./wireless-uwe5622/uwe5622-v6.9.patch;
      # }
    ];
  };
}
