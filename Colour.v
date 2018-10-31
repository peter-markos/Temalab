`timescale 1ns / 1ps

/******************************************/
/*          Mem�ria �r� modul             */
/******************************************/

module Colour(
	input clk,						// 50 Mhz-es rendszer �rajel
	input rst,						// Resetelhet�
	input write,					// �r�si tartom�ny jelz�s�re
	output [5:0] mem_data,		// Az aktu�lis adat, ami megy az SRAM-ra �r�sra
	
	input over
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
		if (over) data <= 000011;
		else begin
			
			//---------------------1------------------
			if((hor_cntr >= 10'd0) && (hor_cntr <= 10'd25))
			
					if((ver_cntr >= 10'd0) && (ver_cntr <= 10'd35)) //1
						data <= 6'b000000;
					else if((ver_cntr >= 10'd35) && (ver_cntr <= 10'd70)) //2
						data <= 6'b000001;
					else if((ver_cntr >= 10'd70) && (ver_cntr <= 10'd105)) //3
						data <= 6'b000010;
					else if((ver_cntr >= 10'd105) && (ver_cntr <= 10'd140)) //4
						data <= 6'b000011;
					else if((ver_cntr >= 10'd140) && (ver_cntr <= 10'd185))  //5
						data <= 6'b000100;
					else if((ver_cntr >= 10'd175) && (ver_cntr <= 10'd210))  //6
						data <= 6'b000101;
					else if((ver_cntr >= 10'd210) && (ver_cntr <= 10'd245))  //7
						data <= 6'b000110;
					else if((ver_cntr >= 10'd245) && (ver_cntr <= 10'd280))  //8
						data <= 6'b000111;
					else if((ver_cntr >= 10'd280) && (ver_cntr <= 10'd315))  //9
						data <= 6'b001000;
					else if((ver_cntr >= 10'd315) && (ver_cntr <= 10'd350))  //10
						data <= 6'b001001;
					else if((ver_cntr >= 10'd350) && (ver_cntr <= 10'd385))  //11
						data <= 6'b001010;
					else if((ver_cntr >= 10'd385) && (ver_cntr <= 10'd420))  //12
						data <= 6'b001011;
					else if((ver_cntr >= 10'd420) && (ver_cntr <= 10'd455))  //13
						data <= 6'b001100;
					else if((ver_cntr >= 10'd455) && (ver_cntr <= 10'd490))  //14
						data <= 6'b001101;
					else if((ver_cntr >= 10'd490) && (ver_cntr <= 10'd525))  //15
						data <= 6'b001110;
					else
						data <= 6'b001111;
						
						
			//----------------------2----------------	
			else if((hor_cntr >= 10'd25) && (hor_cntr <= 10'd50))
			
					if((ver_cntr >= 10'd0) && (ver_cntr <= 10'd35)) //1
						data <= 6'b010000;
					else if((ver_cntr >= 10'd35) && (ver_cntr <= 10'd70)) //2
						data <= 6'b010001;
					else if((ver_cntr >= 10'd70) && (ver_cntr <= 10'd105)) //3
						data <= 6'b010010;
					else if((ver_cntr >= 10'd105) && (ver_cntr <= 10'd140)) //4
						data <= 6'b010011;
					else if((ver_cntr >= 10'd140) && (ver_cntr <= 10'd185))  //5
						data <= 6'b010100;
					else if((ver_cntr >= 10'd175) && (ver_cntr <= 10'd210))  //6
						data <= 6'b010101;
					else if((ver_cntr >= 10'd210) && (ver_cntr <= 10'd245))  //7
						data <= 6'b010110;
					else if((ver_cntr >= 10'd245) && (ver_cntr <= 10'd280))  //8
						data <= 6'b010111;
					else if((ver_cntr >= 10'd280) && (ver_cntr <= 10'd315))  //9
						data <= 6'b011000;
					else if((ver_cntr >= 10'd315) && (ver_cntr <= 10'd350))  //10
						data <= 6'b011001;
					else if((ver_cntr >= 10'd350) && (ver_cntr <= 10'd385))  //11
						data <= 6'b011010;
					else if((ver_cntr >= 10'd385) && (ver_cntr <= 10'd410))  //12
						data <= 6'b011011;
					else if((ver_cntr >= 10'd420) && (ver_cntr <= 10'd455))  //13
						data <= 6'b011100;
					else if((ver_cntr >= 10'd455) && (ver_cntr <= 10'd480))  //14
						data <= 6'b011101;
					else if((ver_cntr >= 10'd490) && (ver_cntr <= 10'd525))  //15
						data <= 6'b011110;
					else
						data <= 6'b011111;
						
			//-----------------3--------------------------			
			else if((hor_cntr >= 10'd50) && (hor_cntr <= 10'd75))
			
					if((ver_cntr >= 10'd0) && (ver_cntr <= 10'd35)) //1
						data <= 6'b100000;
					else if((ver_cntr >= 10'd35) && (ver_cntr <= 10'd70)) //2
						data <= 6'b100001;
					else if((ver_cntr >= 10'd70) && (ver_cntr <= 10'd105)) //3
						data <= 6'b100010;
					else if((ver_cntr >= 10'd105) && (ver_cntr <= 10'd140)) //4
						data <= 6'b100011;
					else if((ver_cntr >= 10'd140) && (ver_cntr <= 10'd185)) //5
						data <= 6'b100100;
					else if((ver_cntr >= 10'd175) && (ver_cntr <= 10'd210))  //6
						data <= 6'b100101;
					else if((ver_cntr >= 10'd210) && (ver_cntr <= 10'd245))  //7
						data <= 6'b100110;
					else if((ver_cntr >= 10'd245) && (ver_cntr <= 10'd280))  //8
						data <= 6'b100111;
					else if((ver_cntr >= 10'd280) && (ver_cntr <= 10'd315))  //9
						data <= 6'b101000;
					else if((ver_cntr >= 10'd315) && (ver_cntr <= 10'd350))  //10
						data <= 6'b101001;
					else if((ver_cntr >= 10'd350) && (ver_cntr <= 10'd385))  //11
						data <= 6'b101010;
					else if((ver_cntr >= 10'd385) && (ver_cntr <= 10'd420))  //12
						data <= 6'b101011;
					else if((ver_cntr >= 10'd420) && (ver_cntr <= 10'd455))  //13
						data <= 6'b101100;
					else if((ver_cntr >= 10'd455) && (ver_cntr <= 10'd490))  //14
						data <= 6'b101101;
					else if((ver_cntr >= 10'd490) && (ver_cntr <= 10'd525))  //15
						data <= 6'b101110;
					else
						data <= 6'b101111;
						
						
			//------------------4--------------------------	
			else //if((hor_cntr >= 10'd75) && (hor_cntr <= 10'd100))
			
					if((ver_cntr >= 10'd0) && (ver_cntr <= 10'd35)) //1
						data <= 6'b110000;
					else if((ver_cntr >= 10'd35) && (ver_cntr <= 10'd70)) //2
						data <= 6'b110001;
					else if((ver_cntr >= 10'd70) && (ver_cntr <= 10'd105)) //3
						data <= 6'b110010;
					else if((ver_cntr >= 10'd105) && (ver_cntr <= 10'd140)) //4
						data <= 6'b110011;
					else if((ver_cntr >= 10'd140) && (ver_cntr <= 10'd185))  //5
						data <= 6'b110100;
					else if((ver_cntr >= 10'd175) && (ver_cntr <= 10'd210))  //6
						data <= 6'b110101;
					else if((ver_cntr >= 10'd210) && (ver_cntr <= 10'd245))  //7
						data <= 6'b110110;
					else if((ver_cntr >= 10'd245) && (ver_cntr <= 10'd280))  //8
						data <= 6'b110111;
					else if((ver_cntr >= 10'd280) && (ver_cntr <= 10'd315))  //9
						data <= 6'b111000;
					else if((ver_cntr >= 10'd315) && (ver_cntr <= 10'd350))  //10
						data <= 6'b111001;
					else if((ver_cntr >= 10'd350) && (ver_cntr <= 10'd385))  //11
						data <= 6'b111010;
					else if((ver_cntr >= 10'd385) && (ver_cntr <= 10'd420))  //12
						data <= 6'b111011;
					else if((ver_cntr >= 10'd420) && (ver_cntr <= 10'd455))  //13
						data <= 6'b111100;
					else if((ver_cntr >= 10'd455) && (ver_cntr <= 10'd480))  //14
						data <= 6'b111101;
					else if((ver_cntr >= 10'd480) && (ver_cntr <= 10'd525))  //14
						data <= 6'b111110;
					else 
						data <= 6'b111111;
		end			
	end
	
	// Csak �r�s k�zben hajtjuk meg az adatvonalat, hogy az olvas�st ne zavarjuk
	assign mem_data = write ? data : 6'bzzzzzz;

endmodule
