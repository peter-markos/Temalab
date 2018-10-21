`timescale 1ns / 1ps

/******************************************/
/*          Memória író modul             */
/******************************************/

module SRAM_256kx16(
	input clk,						// 50 Mhz-es rendszer órajel
	input rst,						// Resetelhetõ
	input write,					// Írási tartomány jelzésére
	output [5:0] mem_data,		// Az aktuális adat, ami megy az SRAM-ra írásra
	input [6:0] hor_ball,		// A labda középpontjának horizontális pozíciója (x)
	input [9:0] ver_ball			// A labda középpontjának vertikális pozíciója (y)
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
		// A zöld platform
		if ((ver_cntr > 10'd499) && (ver_cntr <= 10'd519))
			data <= 6'b001100;
		// A piros labda
		else if (((ver_cntr > ver_ball-10'd24) && (ver_cntr <= ver_ball-10'd20) && (hor_cntr > hor_ball-7'd3) && (hor_cntr <= hor_ball+7'd3)) || 
					((ver_cntr > ver_ball-10'd20) && (ver_cntr <= ver_ball-10'd12) && (hor_cntr > hor_ball-7'd5) && (hor_cntr <= hor_ball+7'd5)) ||
					((ver_cntr > ver_ball-10'd12) && (ver_cntr <= ver_ball+10'd12) && (hor_cntr > hor_ball-7'd6) && (hor_cntr <= hor_ball+7'd6)) ||
					((ver_cntr > ver_ball+10'd12) && (ver_cntr <= ver_ball+10'd20) && (hor_cntr > hor_ball-7'd5) && (hor_cntr <= hor_ball+7'd5)) ||
					((ver_cntr > ver_ball+10'd20) && (ver_cntr <= ver_ball+10'd24) && (hor_cntr > hor_ball-7'd3) && (hor_cntr <= hor_ball+7'd3)))	
			data <= 6'b000011;
		// kék háttér
		else
			data <= 6'b110100;
	end
	
	// Csak írás közben hajtjuk meg az adatvonalat, hogy az olvasást ne zavarjuk
	assign mem_data = write ? data : 6'bzzzzzz;

endmodule
