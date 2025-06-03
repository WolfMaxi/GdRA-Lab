#!/bin/sh
ghdl -a --std=08 ../../packages/constant_package.vhdl
ghdl -a --std=08 ../../packages/types.vhdl
ghdl -a --std=08 ../../components/decoder/decoder.vhdl
ghdl -a --std=08 ../../testbenches/decoder/decoder_u_tb.vhdl
ghdl -e --std=08 decoder_u_tb 
ghdl -r --std=08 decoder_u_tb --vcd=decoder_u_tb.vcd #--stop-time=100ns
