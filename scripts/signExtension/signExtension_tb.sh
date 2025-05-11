#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf

ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/type_packages.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/types.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/Util_Asm_Package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/signExtender/signExtension.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/signExtender/signExtension_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" signExtension_tb
ghdl -r --std=08 --workdir="${workdir}vhdl" signExtension_tb --vcd="${workdir}vhdl/vcd/signExtension_tb.vcd" --stop-time=21094350ns