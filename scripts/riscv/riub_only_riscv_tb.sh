#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf

ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/type_packages.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/types.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/Util_Asm_Package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_half_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_full_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_n_bit_full_adder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/register/PipelineRegister.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/cache/instruction_cache.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/register/controlwordregister.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/decoder/decoder.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/registerfile/register_file.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/multiplexer/gen_mux.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/multiplexer/gen_mux2to1.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/signExtender/signExtension.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/encoder/pc_sel_encoder.vhdl"
# =============== ALU ===============
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_xor.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_or.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_gen_and.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_shifter.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_comparator.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/alu/my_alu.vhdl"
# ===================================
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}riscv/riub_only_RISC_V.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/riscv/riub_only_RISC_V_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" riub_only_RISC_V_tb
ghdl -r --std=08 --workdir="${workdir}vhdl" riub_only_RISC_V_tb --wave="${workdir}vhdl/vcd/riub-only_riscv.ghw" --vcd="${workdir}vhdl/vcd/riub-only_riscv.vcd"