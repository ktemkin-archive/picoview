#
#  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
#  This will hopefully be replaced with an FOSS license soon.
#
#  Copyright (c) Assured Information Security, inc.
#  Author: Kyle J. Temkin
#

COCOTB ?= /usr/local/cocotb-1.0

SRCDIR := $(PWD)/../..

VERILOG_SOURCES := \
	$(SRCDIR)/spi_synchronizer.v \
	$(SRCDIR)/simple_spi.v 

TOPLEVEL = simple_spi
MODULE = test_simple_spi

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
