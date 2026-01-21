# GHDL Makefile - lib + tb (src optional)
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

analyze:
	mkdir -p $(WORKDIR)
	@if [ -n "$(LIBFILES)" ]; then \
		echo "Analyzing lib: $(LIBFILES)"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $(LIBFILES); \
	fi
	@if [ -n "$(SRCFILES)" ]; then \
		echo "Analyzing src: $(SRCFILES)"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $(SRCFILES); \
	fi
	@if [ -n "$(TBFILES)" ]; then \
		echo "Analyzing tb: $(TBFILES)"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir=$(WORKDIR) $(TBFILES); \
	else \
		echo "ERROR: '$(TB)' not found"; exit 1; \
	fi

elaborate:
	$(GHDL) -e $(GHDLFLAGS) --workdir=$(WORKDIR) $(TB_NAME)

sim:
	$(GHDL) -r $(GHDLFLAGS) --workdir=$(WORKDIR) $(TB_NAME) --wave=$(WORKDIR)/$(TB_NAME).ghw --stop-time=300ns

view:
	gtkwave $(WORKDIR)/$(TB_NAME).ghw &

all: clean analyze elaborate sim view
clean:
	rm -rf $(WORKDIR) *.o *.cf

.PHONY: all analyze elaborate sim view clean
