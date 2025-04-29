#!/bin/sh
ghdl -a --std=08 --workdir=../../vhdl ../../packages/constant_package.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../components/register/PipelineRegister.vhdl
ghdl -a --std=08 --workdir=../../vhdl ../../testbenches/register/PipelineRegister_tb.vhdl
ghdl -e --std=08 --workdir=../../vhdl PipelineRegister_tb
ghdl -r --std=08 --workdir=../../vhdl PipelineRegister_tb --stop-time=100ns
 
