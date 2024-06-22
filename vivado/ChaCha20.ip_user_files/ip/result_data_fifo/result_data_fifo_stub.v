// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Sat Jun 22 22:10:01 2024
// Host        : ORANGE running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/FPGA/Kintex/ChaCha20/vivado/ChaCha20.srcs/sources_1/ip/result_data_fifo/result_data_fifo_stub.v
// Design      : result_data_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2019.2" *)
module result_data_fifo(clk, rst, din, wr_en, rd_en, dout, full, empty, 
  data_count, wr_rst_busy, rd_rst_busy)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,din[31:0],wr_en,rd_en,dout[31:0],full,empty,data_count[9:0],wr_rst_busy,rd_rst_busy" */;
  input clk;
  input rst;
  input [31:0]din;
  input wr_en;
  input rd_en;
  output [31:0]dout;
  output full;
  output empty;
  output [9:0]data_count;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
