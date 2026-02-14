# CEG3156-Labs
Repo for my labs for CEG3156 Winter 2026 at uOttawa. Using [GHDL](https://github.com/ghdl/ghdl) and [GTKWave](https://gtkwave.sourceforge.net/) to streamline development

## For new labs
1. copy the lab template folder
2. create a local.mk file in the root of the new lab folder
3. add a line for `TB=pathtotb.vhd`
4. add a line for `STOPTIME=someamountoftime`

Add testbenches to tb folder and lab specific components in the src directory. Any reusable components should be in the lib folder of the repo's route directory

Compile and simulate with `make all`. See Makefile for other options.
