#!/bin/sh
workdir="../../"
rm "${workdir}vhdl/"*.cf

ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/constant_package.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}packages/types.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}components/registerfile/register_file.vhdl"
ghdl -a --std=08 --workdir="${workdir}vhdl" "${workdir}testbenches/registerfile/register_file_r_tb.vhdl"
ghdl -e --std=08 --workdir="${workdir}vhdl" register_file_r_tb
ghdl -r --std=08 --workdir="${workdir}vhdl" register_file_r_tb --vcd="${workdir}vhdl/vcd/register_file_r_tb.vcd" --stop-time=200ns