`timescale 1ns / 1ps

module Top_module(
	input clk,					// 50 MHz-es rendszer �rajel
	input rstbt,
	output [8:0] aio,			// VGA port
	
	input [1:0] bt,
	
	//output [6:0] bo,		// Accelorometer kimeneti port
	//input bi,					// Accelorometer bemeneti port
	
	output [17:0] mem_addr,	// 256k-s SRAM c�mbbitjei
	inout [5:0] mem_data,	// Csak az als� 6 adatbitet haszn�ljuk (3*2 rgb-bit)
	output mem_wen,			// �r�s enged�lyez� (neg�lt logika)
	output mem_lbn,			// Als� 8 adatbit enged�lyez� (neg�lt logika)
	output sram_csn,			// SRAM enged�lyez� (neg�lt logika)
	output sram_oen,			// Kimenetek enged�lyez� (neg�lt logika)
	output sdram_csn			// SDRAM enged�lyez�
    );
	 
	 assign sdram_csn = 1;		// Az SRAM haszn�lata alatt a SDRAM-ot tiltani kell
	 
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
