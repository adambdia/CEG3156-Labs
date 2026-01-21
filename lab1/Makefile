# GHDL Makefile - lib + tb (src optional) - GHDL 5.1.1 Standard Deps
GHDL       = ghdl
GHDLFLAGS  = --std=93 -fexplicit
WORKDIR    = sim
LIBDIR     = ../lib
SRCDIR     = src
TB         = tb/nbitpipo_tb.vhd

# Derived: testbench name without .vhd
TB_NAME    = $(basename $(notdir $(TB)))

LIBFILES   = $(wildcard $(LIBDIR)/*.vhd)
SRCFILES   = $(wildcard $(SRCDIR)/*.vhd)
TBFILES    = $(TB)

# Standard GHDL: -i scans deps, -m auto-analyzes/elaborates TB + deps
analyze:
	mkdir -p $(WORKDIR)
	@echo "Importing deps: $(LIBFILES) $(SRCFILES) $(TBFILES)"
	@$(GHDL) -i $(GHDLFLAGS) --workdir=$(WORKDIR) $(LIBFILES) $(SRCFILES) $(TBFILES)
	@echo "Analyzing + elaborating $(TB_NAME)"
	@$(GHDL) -m $(GHDLFLAGS) --workdir=$(WORKDIR) $(TB_NAME)

elaborate: analyze  # -m already elaborates

sim:
	$(GHDL) -r $(GHDLFLAGS) --workdir=$(WORKDIR) $(TB_NAME) --wave=$(WORKDIR)/$(TB_NAME).ghw --stop-time=300ns

view:
	gtkwave $(WORKDIR)/$(TB_NAME).ghw &

all: clean analyze sim view
clean:
	rm -rf $(WORKDIR) *.o *.cf

.PHONY: all analyze elaborate sim view clean
