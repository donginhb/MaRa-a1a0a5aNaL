# 
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 12228 2008-08-06 22:43:15Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=libplist
PKG_VERSION:=1.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libplist
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library for accessing iPhone/iPod USB devices
  URL:=http://libusb.sourceforge.net/
  DEPENDS:=+libxml2 +glib2
endef

TARGET_CFLAGS += $(FPIC)

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
	USB_PKGCONF_LIBRARY_DIRS="$(STAGING_DIR)/usr/lib" \
	CMAKE_LIBRARY_PATH="$(STAGING_DIR)/usr/lib" \
	CMAKE_INCLUDE_PATH="$(STAGING_DIR)/usr/include" \
	GLIB2_LIBRARIES="$(STAGING_DIR)/usr/lib" \
	GLIB2_MAIN_INCLUDE_DIR="$(STAGING_DIR)/glib-2*/glib" \
	LIBXML2_LIBRARIES="$(STAGING_DIR)/usr/lib" \
	LIBXML2_INCLUDE_DIR="$(STAGING_DIR)/libxml2*/include" \
	cmake $(PKG_BUILD_DIR)/CMakeLists.txt 
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Build/InstallDev
	mkdir -p $(1)/usr/include
	mkdir -p $(1)/usr/include/plist
	$(CP) $(PKG_INSTALL_DIR)/usr/local/include/plist/plist.h $(1)/usr/include/plist/
	mkdir -p $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libplist*.so* $(1)/usr/lib/
	mkdir -p $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/pkgconfig/libplist.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libplist/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libplist*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libplist))
