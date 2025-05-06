#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/type_packages.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/ram/Single_Port_RAM.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/ram/Single_Port_RAM_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" Single_Port_RAM_tb
ghdl -r --std=08 --workdir="${workdir}vhdl" Single_Port_RAM_tb --vcd="${workdir}vhdl/vcd/ram_tb.vcd"
