#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/register/PipelineRegister.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/register/PipelineRegister_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" PipelineRegister_tb
ghdl -r --std=08 --workdir="${workdir}vhdl" PipelineRegister_tb --vcd="${workdir}vhdl/vcd/register_tb.vcd" --stop-time=100ns