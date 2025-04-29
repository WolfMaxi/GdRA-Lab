#!/bin/sh
ghdl -a --std=08 --workdir=../../vhdl ../../packages/constant_package.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/multiplexer/gen_mux.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../testbenches/multiplexer/gen_mux_tb.vhdl
ghdl -e --std=08 --workdir=../../vhdl gen_mux_tb 
ghdl -r --std=08 --workdir=../../vhdl gen_mux_tb --vcd=../../vhdl/vcd/gen_mux_tb.vcd
