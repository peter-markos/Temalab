`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:09:22 10/16/2018 
// Design Name: 
// Module Name:    Top_module 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Top_module(
	input clk,
	input rstbt,
	input [2:0] bt,
	output [8:0] ao,
	output [6:0] bo,
	input bi
    );
	 
	 VGA VGA(.clk(clk), .rst(~rstbt), .bt(bt), .io(aio));
	 Accel Accel(.clk(clk), .miso(bi), .out(bo));


endmodule
