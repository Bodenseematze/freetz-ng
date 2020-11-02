$(call PKG_INIT_LIB, 6.2)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=78c4ede0c11f05e98b0ce5ca0e427f97028e30a92a5bfe56321a30a924c9614a
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_LIBCONFIG_SHORT := ncursesw6-config
$(PKG)_LIBNAMES_SHORT := ncursesw formw menuw panelw
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/lib/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)







$(PKG)_TERMINFO_DIR := /usr/share/terminfo



$(PKG)_CONFIGURE_ENV += cf_cv_func_nanosleep=yes
$(PKG)_CONFIGURE_ENV += cf_cv_link_dataonly=yes
# evaluated by running test program on target platform
$(PKG)_CONFIGURE_ENV += cf_cv_type_of_bool='unsigned char'
# Even though the test says that poll()-function works we prefer
# ncurses' select-based branch and set cf_cv_working_poll to 'no'
$(PKG)_CONFIGURE_ENV += cf_cv_working_poll=no

$(PKG)_CONFIGURE_OPTIONS += --enable-echo
$(PKG)_CONFIGURE_OPTIONS += --enable-const
$(PKG)_CONFIGURE_OPTIONS += --enable-overwrite
$(PKG)_CONFIGURE_OPTIONS += --enable-pc-files
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath-hack
$(PKG)_CONFIGURE_OPTIONS += --without-ada
$(PKG)_CONFIGURE_OPTIONS += --without-cxx
$(PKG)_CONFIGURE_OPTIONS += --without-cxx-binding
$(PKG)_CONFIGURE_OPTIONS += --without-debug
$(PKG)_CONFIGURE_OPTIONS += --without-profile
$(PKG)_CONFIGURE_OPTIONS += --without-progs
$(PKG)_CONFIGURE_OPTIONS += --without-manpages
$(PKG)_CONFIGURE_OPTIONS += --without-tests
$(PKG)_CONFIGURE_OPTIONS += --with-normal
$(PKG)_CONFIGURE_OPTIONS += --with-shared
$(PKG)_CONFIGURE_OPTIONS += --with-terminfo-dirs="$($(PKG)_TERMINFO_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --with-default-terminfo-dir="$($(PKG)_TERMINFO_DIR)"

$(PKG)_CONFIGURE_OPTIONS += --enable-widec
$(PKG)_CONFIGURE_OPTIONS += --with-build-cppflags=-D_GNU_SOURCE

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NCURSESW_DIR) \
		libs panel menu form headers

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(NCURSESW_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install.libs
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(NCURSESW_LIBCONFIG_SHORT)
	$(call PKG_FIX_LIBTOOL_LA,bindir datadir mandir) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(NCURSESW_LIBCONFIG_SHORT)
	$(PKG_FIX_LIBTOOL_LA) $(NCURSESW_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/pkgconfig/%.pc)










$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

define $(PKG)_INSTALL_T_RULE
$(1): $(2)
	$(RM) -r $$(dir $$@); \
	mkdir -p $$(dir $$@); \
	cp -a $$(dir $$<)/* $$(dir $$@); \
	touch $$@
endef







$(pkg): $($(PKG)_LIBS_STAGING_DIR)
$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)




$(pkg)-clean: 
	-$(SUBMAKE) -C $(NCURSESW_DIR) clean
	$(RM) \
		$(NCURSESW_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*) \
		$(NCURSESW_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncursesw* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{ncurses,ncurses_dll,term,curses,unctrl,termcap,eti,menu,form,panel}.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(NCURSESW_LIBCONFIG_SHORT)




$(pkg)-uninstall:
	$(RM) $(NCURSESW_LIBNAMES_SHORT:%=$(NCURSESW_TARGET_DIR)/lib%*)

$(PKG_FINISH)
