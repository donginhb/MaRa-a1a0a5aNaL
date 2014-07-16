# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 12228 2008-08-06 22:43:15Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=libimobiledevice
PKG_VERSION:=1.1.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
LDFLAGS+=-L$(STAGING_DIR)/lib

include $(INCLUDE_DIR)/package.mk

define Package/libimobiledevice
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=A library for accessing Linux iPhone devices
	DEPENDS:=+usbmuxd +libplist +libtasn1 +libiconv
endef

TARGET_CFLAGS += $(FPIC)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CCOPT="-static $(TARGET_CFLAGS)" \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(EZP_CFLAGS) -I. -I$(STAGING_DIR)/usr/include -L$(STAGING_DIR)/usr/lib"
		DESTDIR="$(PKG_INSTALL_DIR)" 
endef

define Build/InstallDev
	$(MAKE) install
	$(INSTALL_DIR) $(1)/usr/include/libimobiledevice
	$(CP) $(PKG_BUILD_DIR)/include/libimobiledevice $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libimobiledevice.so* $(1)/usr/lib/
endef

define Package/libimobiledevice/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libimobiledevice.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libimobiledevice))
