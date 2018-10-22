`timescale 1ns / 1ps

module Accel(
	input clk,
	input miso,
	output [:0] out
    );

assign out[0] = 0;	// ~CS
assign out[1] = 0;	// MISO
assign out[2] = clk;	// SCLK (Osztandó)

endmodule
