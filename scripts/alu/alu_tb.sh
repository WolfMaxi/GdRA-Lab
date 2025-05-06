#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_xor.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_or.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_and.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_shifter.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_half_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_full_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_n_bit_full_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_alu.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/alu/my_alu_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" my_alu_tb
ghdl -r --std=08 --workdir="${workdir}vhdl" my_alu_tb --vcd="${workdir}vhdl/vcd/my_alu_tb.vcd"
