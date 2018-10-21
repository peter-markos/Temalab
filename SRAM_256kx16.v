`timescale 1ns / 1ps

/******************************************/
/*          Mem�ria �r� modul             */
/******************************************/

module SRAM_256kx16(
	input clk,						// 50 Mhz-es rendszer �rajel
	input rst,						// Resetelhet�
	input write,					// �r�si tartom�ny jelz�s�re
	output [5:0] mem_data,		// Az aktu�lis adat, ami megy az SRAM-ra �r�sra
	input [6:0] hor_ball,		// A labda k�z�ppontj�nak horizont�lis poz�ci�ja (x)
	input [9:0] ver_ball			// A labda k�z�ppontj�nak vertik�lis poz�ci�ja (y)
	);
	
	reg [5:0] data;
	
	reg [9:0] ver_cntr = 10'd1;	// verti�lisan, a sorok sz�ml�l�s��rt (600 sor => 10 bit)
	reg [6:0] hor_cntr = 7'd1;		// horizont�lisan, az oszlopok sz�ml�l�s��rt (100 oszlop => 7 bit)
	 
	always @ (posedge clk)
	begin
		if (rst || ~(write)) begin			// Resetre �s nem �r�si tartom�nyban resetelj�k a horizont�lis sz�ml�l�t
			hor_cntr <= 7'd1;
			if (rst) ver_cntr <= 10'd1;	// Vertik�lisat csak resetre (minden soron bel�l t�bbsz�r kil�p�nk �r�si tartom�nyb�l)
		end
		else begin
			if (hor_cntr == 7'd101)												// Ha a sor v�g�re �rt�nk...
				if (ver_cntr != 10'd600) ver_cntr <= ver_cntr + 1'b1;	// �s nem az utols� sorban vagyunk, megy�nk tov�bb
				else ver_cntr <= 10'd1;											// Egy�bk�nt �jraind�tjuk
			else
				hor_cntr <= hor_cntr + 1'b1;									// Egy�bk�nt tov�bbl�p�nk a soron bel�l
		end
	end
	
	always @ (*)		// Kirajzol�sok
	begin
		// A z�ld platform
		if ((ver_cntr > 10'd499) && (ver_cntr <= 10'd519))
			data <= 6'b001100;
		// A piros labda
		else if (((ver_cntr > ver_ball-10'd24) && (ver_cntr <= ver_ball-10'd20) && (hor_cntr > hor_ball-7'd3) && (hor_cntr <= hor_ball+7'd3)) || 
					((ver_cntr > ver_ball-10'd20) && (ver_cntr <= ver_ball-10'd12) && (hor_cntr > hor_ball-7'd5) && (hor_cntr <= hor_ball+7'd5)) ||
					((ver_cntr > ver_ball-10'd12) && (ver_cntr <= ver_ball+10'd12) && (hor_cntr > hor_ball-7'd6) && (hor_cntr <= hor_ball+7'd6)) ||
					((ver_cntr > ver_ball+10'd12) && (ver_cntr <= ver_ball+10'd20) && (hor_cntr > hor_ball-7'd5) && (hor_cntr <= hor_ball+7'd5)) ||
					((ver_cntr > ver_ball+10'd20) && (ver_cntr <= ver_ball+10'd24) && (hor_cntr > hor_ball-7'd3) && (hor_cntr <= hor_ball+7'd3)))	
			data <= 6'b000011;
		// k�k h�tt�r
		else
			data <= 6'b110100;
	end
	
	// Csak �r�s k�zben hajtjuk meg az adatvonalat, hogy az olvas�st ne zavarjuk
	assign mem_data = write ? data : 6'bzzzzzz;

endmodule
