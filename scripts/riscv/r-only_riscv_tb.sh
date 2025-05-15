#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf

ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/type_packages.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/types.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_half_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_full_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_n_bit_full_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/register/PipelineRegister.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/cache/instruction_cache.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/decoder/decoder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/registerfile/register_file.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}riscv/R_only_RISC_V.vhdl"