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
	$(SRCDIR)/offset_sampler.v \
	$(SRCDIR)/dut.v  \
	$(PWD)/mock_ets_clkgen.v

TOPLEVEL = offset_sampler
MODULE = test_offset_sampler

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim
