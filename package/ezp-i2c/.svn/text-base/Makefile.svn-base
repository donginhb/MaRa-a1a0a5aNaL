# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=ezp-i2c
PKG_VERSION:=1.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ezp-i2c
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=I2C command
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" 
endef

define Package/ezp-i2c/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ezp-i2c $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ezp-i2c-init $(1)/etc/init.d/ezp-i2c-init
endef

$(eval $(call BuildPackage,ezp-i2c))
