#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/multiplexer/gen_mux.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/multiplexer/gen_mux_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" gen_mux_tb 
ghdl -r --std=08 --workdir="${workdir}vhdl" gen_mux_tb --vcd="${workdir}vhdl/vcd/gen_mux_tb.vcd" --stop-time=100ns