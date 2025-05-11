#!/bin/sh

ghdl -a --std=08 ../../packages/constant_package.vhdl
ghdl -a --std=08 ../../packages/type_packages.vhdl
ghdl -a --std=08 ../../packages/types.vhdl
ghdl -a --std=08 ../../packages/Util_Asm_Package.vhdl
ghdl -a --std=08 ../../components/signExtender/signExtension.vhdl
ghdl -a --std=08 ../../testbenches/signExtender/signExtension_tb.vhdl
ghdl -e --std=08 signExtension_tb
ghdl -r --std=08 signExtension_tb --vcd=signExtension_tb.vcd  --stop-time=21094350ns