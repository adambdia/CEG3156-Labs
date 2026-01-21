# GHDL Makefile - lib + tb (src optional) - GHDL 5.1.1 Standard Deps
GHDL       = ghdl
GHDLFLAGS  = --std=93 -fexplicit
WORKDIR    = sim
LIBDIR     = ../lib
SRCDIR     = src
# Target Testbench
TB         = tb/mux4x1_tb.vhd
# edit this stop time
STOPTIME = 300ns

# Derived: testbench name without .vhd
TB_NAME    = $(basename $(notdir $(TB)))

LIBFILES   = $(wildcard $(LIBDIR)/*.vhd)
SRCFILES   = $(wildcard $(SRCDIR)/*.vhd)
TBFILES    = $(TB)

# 1. Analyze & Make
# We add '-o $(WORKDIR)/$(TB_NAME)' so the executable is saved inside 'sim/'
analyze:
	mkdir -p $(WORKDIR)
	@echo "Importing deps..."
	@$(GHDL) -i $(GHDLFLAGS) --workdir=$(WORKDIR) $(LIBFILES) $(SRCFILES) $(TBFILES)
	@echo "Compiling binary to $(WORKDIR)/$(TB_NAME)"
	@$(GHDL) -m $(GHDLFLAGS) --workdir=$(WORKDIR) -o $(WORKDIR)/$(TB_NAME) $(TB_NAME)

elaborate: analyze

# 2. Simulate
# We now run the binary directly: ./sim/adder_tb
sim:
	@echo "Running simulation..."
	$(WORKDIR)/$(TB_NAME) --wave=$(WORKDIR)/$(TB_NAME).ghw --stop-time=$(STOPTIME)

# 3. View
view:
	@echo "Opening waveform..."
	gtkwave $(WORKDIR)/$(TB_NAME).ghw &

all: clean analyze sim view

# Clean removes the sim folder and any loose binaries in root
clean:
	rm -rf $(WORKDIR) *.o *.cf $(TB_NAME)

.PHONY: all analyze elaborate sim view clean