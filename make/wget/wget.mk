$(call PKG_INIT_BIN, 1.19.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=0c950b9671881222a4d385b013c9604e98a8025d1988529dfca0e93617744cd2
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wget-gnu

# Rename base64_encode/decode to avoid name clash with the same named functions from GnuTLS
$(PKG)_PATCH_POST_CMDS += find $(abspath $($(PKG)_DIR)) \( -name *.h -o -name *.c \) -type f \
	-exec $(SED) -i -r -e 's,(base64_(en|de)code),wget_\1,g' \{\} \+;

$(PKG)_PATCH_POST_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,lib_z_compress)

# add EXTRA_(C|LD)FLAGS
$(PKG)_PATCH_POST_CMDS += find $(abspath $($(PKG)_DIR)) -name Makefile.in -type f \
	-exec $(SED) -i -r -e 's,^(C|LD)FLAGS[ \t]*=[ \t]*@\1FLAGS@,& $$$$(EXTRA_\1FLAGS),' \{\} \+;
$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_PACKAGE_WGET_WITH_SSL)),y)

ifeq ($(strip $(FREETZ_PACKAGE_WGET_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
$(PKG)_CONFIGURE_OPTIONS += --with-libssl-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-libgnutls-prefix
ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_STATIC_LIBS := $(if $(FREETZ_LIB_libcrypto_WITH_ZLIB),-lz)
endif
endif

ifeq ($(strip $(FREETZ_PACKAGE_WGET_GNUTLS)),y)
$(PKG)_DEPENDS_ON += gnutls
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=gnutls
$(PKG)_CONFIGURE_OPTIONS += --with-libgnutls-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-libssl-prefix
ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_STATIC_LIBS := -ltasn1 -lz -lhogweed -lnettle -lgmp
endif
endif

endif

ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -static
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-iri
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libuuid
$(PKG)_CONFIGURE_OPTIONS += --without-zlib # is only required for compressing warc files
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_WGET_WITH_SSL),,--without-ssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_BUSYBOX_WGET
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_GNUTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WGET_DIR) \
		EXTRA_CFLAGS="$(WGET_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(WGET_EXTRA_LDFLAGS)" \
		STATIC_LIBS="$(WGET_STATIC_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(WGET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WGET_DEST_DIR)/usr/bin/wget-gnu

$(PKG_FINISH)
