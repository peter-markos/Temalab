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
	 
	 wire [6:0] ball_hor;
	 wire [9:0] ball_ver;
	 
	 wire [9:0] platform0_ver;
	 wire [6:0] platform0_hor;
	 wire [5:0] platform0_width;
	 
	 wire [9:0] platform1_ver;
	 wire [6:0] platform1_hor;
	 wire [5:0] platform1_width;
	 
	 wire [9:0] platform2_ver;
	 wire [6:0] platform2_hor;
	 wire [5:0] platform2_width;
	 
	 wire [6:0] platform3_ver;
	 wire [6:0] platform3_hor;
	 wire [5:0] platform3_width;
	 
	 wire [9:0] out_platform_ver;
	 wire [6:0] out_platform_hor;
	 wire [5:0] out_platform_width;
	 
	 wire over;
	 
	 SRAM_256kx16 SRAM_256kx16(
		.clk(clk),
		.rst(~rstbt),
		.write(write),
		.mem_data(mem_data),
		
		.ball_hor(ball_hor),
		.ball_ver(ball_ver),
		
		.platform0_ver(platform0_ver),
		.platform0_hor(platform0_hor),
		.platform0_width(platform0_width),
		
		.platform1_ver(platform1_ver),
		.platform1_hor(platform1_hor),
		.platform1_width(platform1_width),
		
		.platform2_ver(platform2_ver),
		.platform2_hor(platform2_hor),
		.platform2_width(platform2_width),
		
		.platform3_ver(platform3_ver),
		.platform3_hor(platform3_hor),
		.platform3_width(platform3_width),
		
		.out_platform_ver(out_platform_ver),
		.out_platform_hor(out_platform_hor),
		.out_platform_width(out_platform_width),
		
		.over(over)
		);
		
	 ball_movement ball(
		.clk(clk),
		.rst(~rstbt),
		.btn(bt),
		
		.ball_ver(ball_ver),
		.ball_hor(ball_hor),
		
		.platform0_ver(platform0_ver),
		.platform0_hor(platform0_hor),
		.platform0_width(platform0_width),
		
		.platform1_ver(platform1_ver),
		.platform1_hor(platform1_hor),
		.platform1_width(platform1_width),
		
		.platform2_ver(platform2_ver),
		.platform2_hor(platform2_hor),
		.platform2_width(platform2_width),
		
		.platform3_ver(platform3_ver),
		.platform3_hor(platform3_hor),
		.platform3_width(platform3_width),
		
		.out_platform_ver(out_platform_ver),
		.out_platform_hor(out_platform_hor),
		.out_platform_width(out_platform_width),
		
		.over(over)
		);


endmodule
