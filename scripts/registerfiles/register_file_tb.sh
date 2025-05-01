#!/bin/sh
# workdir="../../"
# rm "${workdir}/vhdl/"*.cf

ghdl -a --std=08 ../../packages/constant_package.vhdl
ghdl -a --std=08 ../../packages/type_packages.vhdl
ghdl -a --std=08 ../../components/registerfile/register_file.vhdl
ghdl -a --std=08 ../..//testbenches/registerfile/register_file_tb.vhdl
ghdl -e --std=08 register_file_tb
ghdl -r --std=08 register_file_tb --vcd=register_file_tb.vcd --stop-time=120ns
# gtkwave register_file_tb.vcd