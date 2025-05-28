#!/bin/sh

ghdl -a --std=08 ../../packages/constant_package.vhdl
ghdl -a --std=08 ../../packages/type_packages.vhdl
ghdl -a --std=08 ../../packages/types.vhdl
ghdl -a --std=08 ../../packages/Util_Asm_Package.vhdl
ghdl -a --std=08 ../../components/alu/my_half_adder.vhdl
ghdl -a --std=08 ../../components/alu/my_full_adder.vhdl
ghdl -a --std=08 ../../components/alu/my_gen_n_bit_full_adder.vhdl
ghdl -a --std=08 ../../components/register/PipelineRegister.vhdl
ghdl -a --std=08 ../../components/cache/instruction_cache.vhdl
ghdl -a --std=08 ../../components/register/controlwordregister.vhdl
ghdl -a --std=08 ../../components/decoder/decoder.vhdl
ghdl -a --std=08 ../../components/registerfile/register_file.vhdl
ghdl -a --std=08 ../../components/multiplexer/gen_mux.vhdl
ghdl -a --std=08 ../../components/signExtender/signExtension.vhdl
# =============== ALU ===============
ghdl -a --std=08 ../../components/alu/my_gen_xor.vhdl
ghdl -a --std=08 ../../components/alu/my_gen_or.vhdl
ghdl -a --std=08 ../../components/alu/my_gen_and.vhdl
ghdl -a --std=08 ../../components/alu/my_shifter.vhdl
ghdl -a --std=08 ../../components/alu/my_comparator.vhdl
ghdl -a --std=08 ../../components/alu/my_alu.vhdl
# ===================================
ghdl -a --std=08 ../../riscv/RIU_only_RISC_V.vhdl
ghdl -a --std=08 ../../testbenches/riscv/RIU_only_RISC_V_tb.vhdl
ghdl -e --std=08 RIU_only_RISC_V_tb
ghdl -r --std=08 RIU_only_RISC_V_tb --wave=riu-only_riscv.ghw --vcd=riu-only_riscv.vcd