#
# This is free software, licensed under the Apache License, Version 2.0.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-tailscale-lua
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

LUCI_TITLE:=Tailscale management page for Lua-based LuCI
LUCI_DESCRIPTION:=Full-featured Tailscale status and control page for OpenWrt builds with Lua-only LuCI (e.g. BleachWrt), where the official JS app (luci-app-tailscale-community) cannot register its menu. Status card, peer table with per-IP copy buttons, tabbed device details (overview/connection/traffic/security), paginated logs, start/stop/login with optional auth key, and a link to the Tailscale admin console.
LUCI_DEPENDS:=+tailscale +luci-base +luci-lua-runtime +libubus-lua +rpcd-mod-ucode +ucode-mod-uci
LUCI_PKGARCH:=all

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
