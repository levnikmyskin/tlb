# Makefile for TLB
# Copyright (c) 2023 Alessio Molinari <levnikmyskin at github.com> and others.
# SPDX-License-Identifier: GPL-2.0-or-later
TLBVER := $(shell read _ver _dummy < ./VERSION; printf '%s' "$${_ver:-undef}")

# Evaluate parameters
TLB_SBIN    ?= /usr/sbin
TLB_BIN     ?= /usr/bin
TLB_TLIB    ?= /usr/share/tlb
TLB_FLIB    ?= /usr/share/tlb/func.d
TLB_ULIB    ?= /lib/udev
TLB_BATD    ?= /usr/share/tlb/bat.d
TLB_CONFUSR ?= /etc/tlb.conf
TLB_CONFDIR ?= /etc/tlb.d
TLB_CONFDEF ?= /usr/share/tlb/defaults.conf
TLB_CONFREN ?= /usr/share/tlb/rename.conf
TLB_CONFDPR ?= /usr/share/tlb/deprecated.conf
TLB_CONF    ?= /etc/default/tlb
TLB_SYSD    ?= /lib/systemd/system
TLB_SDSL    ?= /lib/systemd/system-sleep
TLB_SYSV    ?= /etc/init.d
TLB_ELOD    ?= /lib/elogind/system-sleep
TLB_SHCPL   ?= /usr/share/bash-completion/completions
TLB_ZSHCPL  ?= /usr/share/zsh/site-functions
TLB_MAN     ?= /usr/share/man
TLB_META    ?= /usr/share/metainfo
TLB_RUN     ?= /run/tlb
TLB_VAR     ?= /var/lib/tlb
TPACPIBAT   ?= $(TLB_TLIB)/tpacpi-bat

# Catenate DESTDIR to paths
_SBIN    = $(DESTDIR)$(TLB_SBIN)
_BIN     = $(DESTDIR)$(TLB_BIN)
_TLIB    = $(DESTDIR)$(TLB_TLIB)
_FLIB    = $(DESTDIR)$(TLB_FLIB)
_ULIB    = $(DESTDIR)$(TLB_ULIB)
_BATD    = $(DESTDIR)$(TLB_BATD)
_CONFUSR = $(DESTDIR)$(TLB_CONFUSR)
_CONFDIR = $(DESTDIR)$(TLB_CONFDIR)
_CONFDEF = $(DESTDIR)$(TLB_CONFDEF)
_CONFREN = $(DESTDIR)$(TLB_CONFREN)
_CONFDPR = $(DESTDIR)$(TLB_CONFDPR)
_CONF    = $(DESTDIR)$(TLB_CONF)
_SYSD    = $(DESTDIR)$(TLB_SYSD)
_SDSL    = $(DESTDIR)$(TLB_SDSL)
_SYSV    = $(DESTDIR)$(TLB_SYSV)
_ELOD    = $(DESTDIR)$(TLB_ELOD)
_SHCPL   = $(DESTDIR)$(TLB_SHCPL)
_ZSHCPL  = $(DESTDIR)$(TLB_ZSHCPL)
_MAN     = $(DESTDIR)$(TLB_MAN)
_META    = $(DESTDIR)$(TLB_META)
_RUN     = $(DESTDIR)$(TLB_RUN)
_VAR     = $(DESTDIR)$(TLB_VAR)
_TPACPIBAT = $(DESTDIR)$(TPACPIBAT)

SED = sed \
	-e "s|@TLBVER@|$(TLBVER)|g" \
	-e "s|@TLB_SBIN@|$(TLB_SBIN)|g" \
	-e "s|@TLB_TLIB@|$(TLB_TLIB)|g" \
	-e "s|@TLB_FLIB@|$(TLB_FLIB)|g" \
	-e "s|@TLB_ULIB@|$(TLB_ULIB)|g" \
	-e "s|@TLB_BATD@|$(TLB_BATD)|g" \
	-e "s|@TLB_CONFUSR@|$(TLB_CONFUSR)|g" \
	-e "s|@TLB_CONFDIR@|$(TLB_CONFDIR)|g" \
	-e "s|@TLB_CONFDEF@|$(TLB_CONFDEF)|g" \
	-e "s|@TLB_CONFREN@|$(TLB_CONFREN)|g" \
	-e "s|@TLB_CONFDPR@|$(TLB_CONFDPR)|g" \
	-e "s|@TLB_CONF@|$(TLB_CONF)|g" \
	-e "s|@TLB_RUN@|$(TLB_RUN)|g"   \
	-e "s|@TLB_VAR@|$(TLB_VAR)|g"   \
	-e "s|@TPACPIBAT@|$(TPACPIBAT)|g"

INFILES = \
	tlb \
	tlb.conf \
	tlb-func-base \
	tlb-readconfs \
	tlb.service \
	tlb-stat \
	tlb.upstart \

MANFILES8 = \
	tlb.8 \
	tlb-stat.8 \

SHFILES = \
	tlb.in \
	tlb-func-base.in \
	func.d/* \
	bat.d/* \
	tlb-stat.in \

PLFILES = \
	tlb-readconfs.in \

BATDRVFILES = $(foreach drv,$(wildcard bat.d/[0-9][0-9]-[a-z]*),$(drv)~)

# Make targets
all: $(INFILES)

$(INFILES): %: %.in
	$(SED) $< > $@

clean:
	rm -f $(INFILES)
	rm -f bat.d/*~

install-man-tlb:
	# manpages
	install -d -m 755 $(_MAN)/man8
	cd man && install -m 644 $(MANFILES8) $(_MAN)/man8/

install-tlb: all
	# Package tlb
	install -D -m 755 tlb $(_SBIN)/tlb
	install -m 755 tlb-stat $(_BIN)/
	install -D -m 755 -t $(_TLIB)/func.d func.d/*
	install -m 755 tlb-func-base $(_TLIB)/
	install -D -m 755 -t $(_TLIB)/bat.d bat.d/*
	install -m 755 tlb-readconfs $(_TLIB)/
ifneq ($(TLB_NO_TPACPI),1)
	install -D -m 755 tpacpi-bat $(_TPACPIBAT)
endif
	[ -f $(_CONFUSR) ] || install -D -m 644 tlb.conf $(_CONFUSR)
	install -d $(_CONFDIR)
ifneq ($(TLB_NO_INIT),1)
	install -D -m 755 tlb.init $(_SYSV)/tlb
endif
ifneq ($(TLB_WITH_SYSTEMD),0)
	install -D -m 644 tlb.service $(_SYSD)/tlb.service
endif


install: install-tlb 

install-man: install-man-tlb

uninstall-tlb:
	# Package tlb
	rm $(_SBIN)/tlb
	rm $(_BIN)/tlb-stat
	rm -r $(_TLIB)
	rm -f $(_SYSV)/tlb
	rm -f $(_SYSD)/tlb.service

uninstall: uninstall-tlb 

checkall: checkbashisms shellcheck perlcritic checkdupconst checkbatdrv checkwip

checkbashisms:
	@echo "*** checkbashisms ***************************************************************************"
	@checkbashisms $(SHFILES) || true

shellcheck:
	@echo "*** shellcheck ******************************************************************************"
	@shellcheck -s dash $(SHFILES) || true

perlcritic:
	@echo "*** perlcritic ******************************************************************************"
	@perlcritic --severity 4 --verbose "%F: [%p] %m at line %l, column %c.  (Severity: %s)\n" $(PLFILES) || true

checkdupconst:
	@echo "*** checkdupconst ***************************************************************************"
	@{ sed -n -r -e 's,^.*readonly\s+([A-Za-z_][A-Za-z_0-9]*)=.*$$,\1,p' $(SHFILES) | sort | uniq -d; } || true

checkwip:
	@echo "*** checkwip ********************************************************************************"
	@grep -E -n "### (DEBUG|DEVEL|TODO|WIP)" $(SHFILES) $(PLFILES) || true

bat.d/TEMPLATE~: bat.d/TEMPLATE
	@awk '/^batdrv_[a-z_]+ ()/ { print $$1; }' $< | grep -v 'batdrv_is' | sort > $@

bat.d/%~: bat.d/%
	@printf "*** checkbatdrv %-25s ***********************************************\n" "$<"
	@awk '/^batdrv_[a-z_]+ ()/ { print $$1; }' $< | grep -v 'batdrv_is' | sort > $@
	@diff -U 1 -s bat.d/TEMPLATE~  $@ || true

checkbatdrv: bat.d/TEMPLATE~ $(BATDRVFILES)
	rm -f bat.d/*~
