`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:29:06 11/13/2018 
// Design Name: 
// Module Name:    rategen 
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
module rategen(
	input clk,
	input rst,
	output start
    );
	 
	reg out;
   reg [21:0]       clkCount = 22'h000000;
   parameter [21:0] cntEndVal = 22'h30D400;

	always @(posedge clk)
	
		if (rst) begin
			out <= 1'b0;
			clkCount <= 22'h000000;
		end
		else begin
			if (clkCount == cntEndVal) begin
				out <= (~out);
				clkCount <= 22'h000000;
			end
			else begin
				clkCount <= clkCount + 1'b1;
			end
		end
	assign start = out;


endmodule
