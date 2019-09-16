$(call PKG_INIT_LIB, 1.1.0)
$(PKG)_LIB_VERSION:=1.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=5f4640a7e93ae6494f24a881414e5c343f803365
$(PKG)_SITE:=https://download.videolan.org/pub/videolan/libdvbcsa/$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libdvbcsa.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdvbcsa.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libdvbcsa.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBDVBCSA_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBDVBCSA_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdvbcsa.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBDVBCSA_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdvbcsa* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libdvbcsa \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/doc/libdvbcsa

$(pkg)-uninstall:
	$(RM) $(LIBDVBCSA_TARGET_DIR)/libdvbcsa.so*

$(PKG_FINISH)
