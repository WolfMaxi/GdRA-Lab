#!/bin/sh
ghdl -a --std=08 --workdir=../../vhdl ../../packages/constant_package.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_gen_xor.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_gen_or.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_gen_and.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_shifter.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_half_adder.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_full_adder.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_gen_n_bit_full_adder.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/alu/my_alu.vhdl