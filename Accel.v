`timescale 1ns / 1ps

module Accel(
	input clk,
	input miso,
	output [6:0] out,
    );

assign out[0] = 0;	// ~CS
assign out[1] = 0;	// MOSI
assign out[2] = clk;	// SCLK (Osztandó)
assign out[3] = 0;	// GND
assign out[4] = 0;	// GND
assign out[5] = 1;	// VCC
assign out[6] = 1;	// VCC

endmodule
