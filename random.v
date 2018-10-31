`timescale 1ns / 1ps

module random(
	input [6:0] max,
	input [1:0] btn,
	input clk,
	
	output reg [6:0] out
    );
	 
	 reg [6:0] cntr = 7'b0;
	 
	 always @ (posedge clk)
	 begin
		if (cntr == max) cntr <= 7'b0;
		else cntr <= cntr + 1'b1;
		if ((btn[0]==1) || (btn[1]==1)) out <= cntr;
	 end

endmodule
