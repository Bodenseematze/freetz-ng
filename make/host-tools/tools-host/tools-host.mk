$(call TOOLS_INIT, 2025-01-08)
$(PKG)_SOURCE:=tools-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=6fbc59e4c466a904d6fda4007c89ab7ed1c81f50fdeebe2d872dfc73ce60db20
$(PKG)_SITE:=@MIRROR/
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON:=kconfig-host

$(PKG)_TARBALL_STRIP_COMPONENTS:=0


define $(PKG)_CUSTOM_UNPACK
	tar -C $($(PKG)_DIR) $(VERBOSE) -xf $(DL_DIR)/$($(PKG)_SOURCE)
endef

#$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
#$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
#	$(info ERROR: File '$(DL_DIR)/$(TOOLS_HOST_SOURCE)' not found.)
#	$(info There is and will no download source be available.)
#	$(info Either disable 'FREETZ_HOSTTOOLS_DOWNLOAD' in menuconfig or)
#	$(info create the file by yourself with 'tools/dl-hosttools own'.)
#	$(error )
$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(TOOLS_HOST_DIR)/tools $(FREETZ_BASE_DIR)/
	touch $@

$($(PKG)_DIR)/.fixhardcoded: $($(PKG)_DIR)/.installed | $(patsubst %,%-fixhardcoded,$(TOOLS))
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.fixhardcoded


$(pkg)-clean:
	-$(RM) $(TOOLS_HOST_DIR)/.{configured,compiled,installed,fixhardcoded}

$(pkg)-dirclean:
	$(RM) -r $(TOOLS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean $(patsubst %,%-distclean,$(filter-out $(TOOLS_BUILD_LOCAL),$(TOOLS)))

$(TOOLS_FINISH)
