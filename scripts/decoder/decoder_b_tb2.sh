#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/types.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/Util_Asm_Package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/decoder/decoder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/decoder/decoder_b_tb2.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" decoder_b_tb2 
ghdl -r --std=08 --workdir="${workdir}vhdl" decoder_b_tb2 --vcd="${workdir}vhdl/vcd/decoder_b_tb2.vcd"
