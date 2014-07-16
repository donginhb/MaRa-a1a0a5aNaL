# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
# Copyright (C) 2008 Frank Cervenka
#
# This is free software, licensed under the GNU General Public License v2.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=usbmuxd
PKG_VERSION:=1.0.7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/usbmuxd
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=USB muxd
	DEPENDS:=+libusb-1.0
endef

define Build/Configure
	IN_OPENWRT=1 \
	AR="$(TARGET_CROSS)ar" \
	AS="$(TARGET_CC) -c $(TARGET_CFLAGS)" \
	LD="$(TARGET_CROSS)ld" \
	NM="$(TARGET_CROSS)nm" \
	CC="$(TARGET_CC)" \
	GCC="$(TARGET_CC)" \
	CXX="$(TARGET_CROSS)g++" \
	RANLIB="$(TARGET_CROSS)ranlib" \
	STRIP="$(TARGET_CROSS)strip" \
	OBJCOPY="$(TARGET_CROSS)objcopy" \
	OBJDUMP="$(TARGET_CROSS)objdump" \
	TARGET_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	USB_PKGCONF_INCLUDE_DIRS="$(STAGING_DIR)/usr/include" \
	USB_PKGCONF_LIBRARY_DIRS="$(STAGING_DIR)/usr/lib"\
	CMAKE_LIBRARY_PATH="$(STAGING_DIR)/usr/lib"\
	cmake $(PKG_BUILD_DIR)/CMakeLists.txt
endef

define Package/usbmuxd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/libusbmuxd/libusbmuxd.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/daemon/usbmuxd $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/tools/iproxy $(1)/usr/bin/
endef

define Build/InstallDev
	mkdir -p $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/libusbmuxd/usbmuxd.h $(1)/usr/include/
	mkdir -p $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libusbmuxd/libusbmuxd.so* $(1)/usr/lib/
	mkdir -p $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/libusbmuxd.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,usbmuxd))
