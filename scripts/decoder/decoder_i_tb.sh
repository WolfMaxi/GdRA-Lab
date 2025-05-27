#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/types.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/decoder/decoder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/decoder/decoder_i_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" decoder_i_tb
ghdl -r --std=08 --workdir="${workdir}vhdl" decoder_i_tb --vcd="${workdir}vhdl/vcd/decoder_i_tb.vcd" --stop-time=100ns
