#!/bin/bash

TOP="top"
UVM_TESTNAME="load_test"

SOURCES_SV=" \
    ./src/LineBuffer.sv \
    ./uvm/LineBuffer/seq_pkg.sv \
    ./uvm/LineBuffer/ref_model_pkg.sv \
    ./uvm/LineBuffer/env_pkg.sv \
    ./uvm/LineBuffer/rand_test_pkg.sv \
    ./uvm/LineBuffer/load_test_pkg.sv \
    ./uvm/LineBuffer/top.sv \
"

COMP_OPTS_SV=" \
    --incr \
    --relax \
    -L uvm \
    --nolog
"

DEFINES_SV=""

echo
echo "### COMPILING SYSTEMVERILOG ###"
xvlog -sv $SOURCES_SV $COMP_OPTS_SV $DEFINES_SV
if [ $? -ne 0 ]; then
    echo "### SYSTEMVERILOG COMPILATION FAILED ###"
    exit 10
fi

echo
echo "### ELABORATING SYSTEMVERILOG ###"
xelab -debug typical -top $TOP -snapshot tb_snapshot -timescale 1ns/1ps -incr
if [ $? -ne 0 ]; then
    echo "### SYSTEMVERILOG ELABORATION FAILED ###"
    exit 11
fi

echo
echo "### SIMULATING SYSTEMVERILOG ###"

# Why curly brackets? I HAVE NO IDEA but it wont work otherwise. 
# See: https://support.xilinx.com/s/question/0D54U00008K8MUzSAN/cant-run-xsim-from-makefile?language=en_US
xsim tb_snapshot --tclbatch ./uvm/LineBuffer/run/xsim_cfg.tcl --testplusarg "{ UVM_TESTNAME="$UVM_TESTNAME" }"

if [ "$1" == "waves" ]; then
    echo "### OPENING WAVES ###"
    xsim --gui tb_snapshot.wdb -view ./uvm/LineBuffer/run/tb_snapshot.wcfg
fi