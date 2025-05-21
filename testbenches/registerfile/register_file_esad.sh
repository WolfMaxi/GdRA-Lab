#!/bin/sh

ghdl -a --std=08  ../../packages/constant_package.vhdl
ghdl -a --std=08  ../../packages/types.vhdl
ghdl -a --std=08  ../../components/registerfile/register_file.vhdl
ghdl -a --std=08  ../../testbenches/registerfile/register_file_tb2.vhdl
ghdl -e --std=08  register_file_tb2
ghdl -r --std=08  register_file_tb2 --vcd=register_file_tb2.vcd --stop-time=50ns
#gtkwave ../../vhdl/vcd/register/register_file_tb.vcd