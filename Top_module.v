`timescale 1ns / 1ps

module Top_module(
	input clk,					// 50 MHz-es rendszer órajel
	input rstbt,
	
	output [7:0] ld,
	input [2:0] bt,
	
	output [2:0] bo,			// Accelorometer kimeneti port
	input bi						// Accelorometer bemeneti port
    );
	 
	 wire start;
	 
	 wire [9:0]   xAxis;		// x-axis data from PmodACL
    wire [9:0]   yAxis;		// y-axis data from PmodACL
    wire [9:0]   zAxis;		// z-axis data from PmodACL
	 
	 reg [7:0] dout;
	 
	 always @ (posedge clk)
	 case(bt)
		3'b001: dout <= xAxis[7:0];
		3'b010: dout <= yAxis[7:0];
		3'b100: dout <= zAxis[7:0];
		default: dout <= 8'b0;
	 endcase
	 
	 assign ld = dout;
	 
	 rategen genStart(
		.clk(clk),
		.rst(~rstbt),
		.start(start)
	 );
	 
	 SPIcomponent Accel( 
		.clk(clk),
		.rst(~rstbt),
		.start(start),
		.bi(bi),
		
		.bo(bo),
		.xAxis(xAxis),
		.yAxis(yAxis),
		.zAxis(zAxis)
    );

endmodule
