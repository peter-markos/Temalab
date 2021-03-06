`timescale 1ns / 1ps

module Top_module(
	input clk,					// 50 MHz-es rendszer �rajel
	input rstbt,				// Reset
	
	output [8:0] aio,			// VGA port
	
	output [2:0] bo,			// Accelorometer kimeneti portjai: 2-SCLK, 1-MOSI, 0-nCS
	input bi,					// Accelorometer bemeneti portja: MISO
	
	output [17:0] mem_addr,	// 256k-s SRAM c�mbbitjei
	inout [5:0] mem_data,	// Csak az als� 6 adatbitet haszn�ljuk (3*2 rgb-bit)
	output mem_wen,			// �r�s enged�lyez� (neg�lt logika)
	output mem_lbn,			// Als� 8 adatbit enged�lyez� (neg�lt logika)
	output sram_csn,			// SRAM enged�lyez� (neg�lt logika)
	output sram_oen,			// Kimenetek enged�lyez� (neg�lt logika)
	output sdram_csn			// SDRAM enged�lyez�
    );
	 
	 assign sdram_csn = 1;	// Az SRAM haszn�lata alatt a SDRAM-ot tiltani kell
	 
	 wire [7:0] ver_addr;	// Megadja h�nyadik sorban vagyunk (0-150)
	 wire [6:0] hor_addr;	// Megadja h�nyadik sorban vagyunk (0-100)
	 wire read;					// Mem�riolvas�s jelz�se
	 wire write;				// Mem�ri�r�s jelz�se
	 
	 assign mem_addr = {5'b0, ver_addr, hor_addr};	// A k�perny� koordin�t�kb�l k�pezz�k a mem�riac�meket
	 assign mem_wen = ~write;								// A megfelel� mem�riavez�rl�k enged�lyez�se
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
	 
	 wire [6:0] ball_hor;
	 wire [9:0] ball_ver;
	 
	 wire [7:0] platform0_ver;
	 wire [6:0] platform0_hor;
	 wire [5:0] platform0_width;
	 
	 wire [6:0] platform1_ver;
	 wire [6:0] platform1_hor;
	 wire [4:0] platform1_width;
	 
	 wire [5:0] platform2_ver;
	 wire [6:0] platform2_hor;
	 wire [4:0] platform2_width;
	 
	 wire [4:0] platform3_ver;
	 wire [6:0] platform3_hor;
	 wire [4:0] platform3_width;
	 
	 wire [7:0] out_platform_ver;
	 wire [6:0] out_platform_hor;
	 wire [5:0] out_platform_width;
	 
	 wire right;
	 wire left;
	 wire middle;
	 
	 wire over;
	 //wire [19:0] score;
	 
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
		
	 Accelo Accelo(
		.clk(clk),
		.rst(~rstbt),
		
		.bo(bo),
		.bi(bi),
		
		.right(right),
		.left(left),
		.middle(middle)
		);
		
	 ball_movement ball(
		.clk(clk),
		.rst(~rstbt),
		
		.right(right),
		.left(left),
		.middle(middle),
		
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
		
		//.score(score)
		.over(over)
		);


endmodule
