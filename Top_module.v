`timescale 1ns / 1ps

module Top_module(
	input clk,					// 50 MHz-es rendszer órajel
	input rstbt,
	output [8:0] aio,			// VGA port
	
	input [1:0] bt,
	
	//output [6:0] bo,		// Accelorometer kimeneti port
	//input bi,					// Accelorometer bemeneti port
	
	output [17:0] mem_addr,	// 256k-s SRAM címbbitjei
	inout [5:0] mem_data,	// Csak az alsó 6 adatbitet használjuk (3*2 rgb-bit)
	output mem_wen,			// Írás engedélyezõ (negált logika)
	output mem_lbn,			// Alsó 8 adatbit engedélyezõ (negált logika)
	output sram_csn,			// SRAM engedélyezõ (negált logika)
	output sram_oen,			// Kimenetek engedélyezõ (negált logika)
	output sdram_csn			// SDRAM engedélyezõ
    );
	 
	 assign sdram_csn = 1;		// Az SRAM használata alatt a SDRAM-ot tiltani kell
	 
	 wire [6:0] hor_addr;
	 wire [7:0] ver_addr;
	 wire read;
	 wire write;
	 assign mem_addr = {5'b0, ver_addr, hor_addr};
	 assign mem_wen = ~write;
	 assign mem_lbn = ~(read || write);
	 assign sram_csn = ~(read || write);
	 assign sram_oen = ~(read || write);
	 
	 VGA VGA(
		.clk(clk),
		.rst(~rstbt),
		.data(mem_data),
		.io(aio),
		.hor_addr(hor_addr),
		.ver_addr(ver_addr),
		.read(read),
		.write(write)
		);
	 //Accel Accel(.clk(clk), .miso(bi), .out(bo));
	 
	 wire [6:0] hor_ball;
	 wire [9:0] ver_ball;
	 
	 SRAM_256kx16 SRAM_256kx16(
		.clk(clk),
		.rst(~rstbt),
		.write(write),
		.mem_data(mem_data),
		.hor_ball(hor_ball),
		.ver_ball(ver_ball)
		);
		
	 ball_movement ball(
		.clk(clk),
		.rst(~rstbt),
		.btn(bt),
		.ver_pos(ver_ball),
		.hor_pos(hor_ball)
		);


endmodule
