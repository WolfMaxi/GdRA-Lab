#!/bin/sh
sh analyse_alu.sh
ghdl -a --std=08 --workdir=../../vhdl ../../testbenches/alu/my_alu_tb.vhdl
ghdl -e --std=08 --workdir=../../vhdl my_alu_tb
ghdl -r --std=08 --workdir=../../vhdl my_alu_tb --vcd=../../vhdl/vcd/my_alu_tb.vcd
