`timescale 1ns / 1ps

/******************************************/
/*          Memória író modul             */
/******************************************/

module SRAM_256kx16(
	input clk,						// 50 Mhz-es rendszer órajel
	input rst,						// Resetelhetõ
	input write,					// Írási tartomány jelzésére
	output [5:0] mem_data,		// Az aktuális adat, ami megy az SRAM-ra írásra
	
	input [6:0] ball_hor,		// A labda középpontjának horizontális pozíciója (x)
	input [9:0] ball_ver,		// A labda középpontjának vertikális pozíciója (y)
	
	input [9:0] platform0_ver,
	input [6:0] platform0_hor,
	input [5:0] platform0_width,
	
	input [9:0] platform1_ver,
	input [6:0] platform1_hor,
	input [5:0] platform1_width,
	
	input [9:0] platform2_ver,
	input [6:0] platform2_hor,
	input [5:0] platform2_width,
	
	input [6:0] platform3_ver,
	input [6:0] platform3_hor,
	input [5:0] platform3_width,
	
	input [9:0] out_platform_ver,
	input [6:0] out_platform_hor,
	input [5:0] out_platform_width,
	
	input over
	);
	
	reg [5:0] data;
	
	reg [9:0] ver_cntr = 10'd1;	// vertiálisan, a sorok számlálásáért (600 sor => 10 bit)
	reg [6:0] hor_cntr = 7'd1;		// horizontálisan, az oszlopok számlálásáért (100 oszlop => 7 bit)
	 
	always @ (posedge clk)
	begin
		if (rst || ~(write)) begin			// Resetre és nem írási tartományban reseteljük a horizontális számlálót
			hor_cntr <= 7'd1;
			if (rst) ver_cntr <= 10'd1;	// Vertikálisat csak resetre (minden soron belül többször kilépünk írási tartományból)
		end
		else begin
			if (hor_cntr == 7'd101)												// Ha a sor végére értünk...
				if (ver_cntr != 10'd600) ver_cntr <= ver_cntr + 1'b1;	// És nem az utolsó sorban vagyunk, megyünk tovább
				else ver_cntr <= 10'd1;											// Egyébként újraindítjuk
			else
				hor_cntr <= hor_cntr + 1'b1;									// Egyébként továbblépünk a soron belül
		end
	end
	
	always @ (*)		// Kirajzolások
	begin
		if (over) data <= 000011;
		else begin
			if ((ver_cntr >= 10'd0) && (ver_cntr <= 10'd39) && (hor_cntr >= 7'd6) && (hor_cntr <= 7'd96))
				data <= 6'b000000;
			// A zöld platformok
			else if (((ver_cntr >= out_platform_ver) && (ver_cntr <= out_platform_ver + 10'd19) && (hor_cntr > out_platform_hor - out_platform_width) && (hor_cntr <= out_platform_hor + out_platform_width + 1'b1)) ||
						((ver_cntr >= platform0_ver) && (ver_cntr <= platform0_ver + 10'd19) && (hor_cntr > platform0_hor - platform0_width) && (hor_cntr <= platform0_hor + platform0_width + 1'b1)) ||
						((ver_cntr >= platform1_ver) && (ver_cntr <= platform1_ver + 10'd19) && (hor_cntr > platform1_hor - platform1_width) && (hor_cntr <= platform1_hor + platform1_width + 1'b1)) ||
						((ver_cntr >= platform2_ver) && (ver_cntr <= platform2_ver + 10'd19) && (hor_cntr > platform2_hor - platform2_width) && (hor_cntr <= platform2_hor + platform2_width + 1'b1)) ||
						((ver_cntr >= platform3_ver) && (ver_cntr <= platform3_ver + 7'd19) && (hor_cntr > platform3_hor - platform2_width) && (hor_cntr <= platform3_hor + platform3_width + 1'b1)))
				data <= 6'b001100;
			// A piros labda
			else if (((ver_cntr > ball_ver-10'd20) && (ver_cntr <= ball_ver-10'd16) && (hor_cntr > ball_hor-7'd1) && (hor_cntr <= ball_hor+7'd2)) || 
						((ver_cntr > ball_ver-10'd16) && (ver_cntr <= ball_ver-10'd8)  && (hor_cntr > ball_hor-7'd3) && (hor_cntr <= ball_hor+7'd4)) ||
						((ver_cntr > ball_ver-10'd8)  && (ver_cntr <= ball_ver+10'd8)  && (hor_cntr > ball_hor-7'd4) && (hor_cntr <= ball_hor+7'd5)) ||
						((ver_cntr > ball_ver+10'd8)  && (ver_cntr <= ball_ver+10'd16) && (hor_cntr > ball_hor-7'd3) && (hor_cntr <= ball_hor+7'd4)) ||
						((ver_cntr > ball_ver+10'd16) && (ver_cntr <= ball_ver+10'd20) && (hor_cntr > ball_hor-7'd1) && (hor_cntr <= ball_hor+7'd2)))	
				data <= 6'b000011;
			// kék háttér
			else
				data <= 6'b110100;
		end
	end
	
	// Csak írás közben hajtjuk meg az adatvonalat, hogy az olvasást ne zavarjuk
	assign mem_data = write ? data : 6'bzzzzzz;

endmodule
