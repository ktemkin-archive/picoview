#
#  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
#  This will hopefully be replaced with an FOSS license soon.
#
#  Copyright (c) Assured Information Security, inc.
#  Author: Kyle J. Temkin
#

# Project Metadata
PROJECT     := picoview
DEVICE      := 8k
CONSTRAINTS := $(PROJECT).pcf

# Normally, we want to produce the final bitstream.
all: $(PROJECT).bin

# Project heirarchy.
$(PROJECT).blif: $(PROJECT).v spi_synchronizer.v simple_spi.v offset_sampler.v dut.v ets_clkgen.v
$(PROJECT).asc: $(PROJECT).blif

# Generic build instructions.
%.blif: %.v
	yosys -q -p "synth_ice40 -blif $@" $^

%.asc: %.blif $(CONSTRAINTS)
	arachne-pnr -q -d $(DEVICE) -p $(CONSTRAINTS) $< -o $@

%.bin: %.asc $(CONSTRAINTS)
	icepack $< $@


.PHONY: clean prog_ram prog

prog_ram: $(PROJECT).bin
	iceprog -S $(PROJECT).bin

prog: $(PROJECT).bin
	iceprog $(PROJECT).bin

clean:
	rm -f *.blif *.asc *.bin
