`timescale 1ns / 1ps

/******************************************/
/*      Accelorometer vez�rl� modul       */
/******************************************/

module Accelo(
	input clk,			// 50 MHz-es rendszer�rajel
	input rst,			// Resetelhet�
	
	output [2:0] bo,	// Accelorometer kimeneti portjai: 2-SCLK, 1-MOSI, 0-nCS
	input bi,			// Accelorometer bemeneti portja: MISO
	
	output right,		// Jobbramozg�s jelz�se
	output left,		// Balramozg�s jelz�se
	output middle		// Alaphelyzet jelz�se
    );
	 
	 reg MOSI, SCLK, nCS;	// SPI vez�rl� jelek
	 
	 reg [17:0] cntr;			// �rajel oszt�shoz sz�ml�l�. 50 Mhz => 100 Hz 249999 ut�n kell v�ltani
	 reg [7:0] out;			// A sorosan kapott 8 bites adat elt�rol�s�ra
	 reg [4:0] sclk_cntr;	//	Egy �r�si/olvas�si ciklusban eltelt �rajelperi�dusok sz�mol�s�ra
	 reg sclk_en;				// Az SPI �rajel enged�lyez�se (neg�lt logika)
	 reg read = 1'b0;			// Olvas�s / �r�s
	 
	 reg measure = 1'b1;		// POWER_CTL regiszter Measure bitj�t 1-be �ll�tani a m�r�s enged�lyez�s�hez
	 reg range = 1'b0;		// DATA_FORMAT regiszter-ben a Range-t 01-re �ll�tani a 4g-s m�r�si tartom�nyhoz
	 reg [5:0] act_address = 6'h2D;	// Az aktu�lisan haszn�lt regiszter c�me
	 reg [1:0] act_data_cntr = 2'b0;	// Sz�mon tartani, hogy h�ny regisztert kezelt�nk
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin						// Resetre minden alaphelyzetbe
			cntr <= 18'b0;
			SCLK <= 1'b0;
			sclk_cntr <= 5'b0;
			sclk_en <= 1'b1;				// Tiltjuk az �rajelet
			act_data_cntr <= 2'b0;
			measure = 1'b1;				// Els�re a POWER_CTL Measure bitj�t �ll�tjuk be
			range = 1'b0;
			act_address <= 6'h2D;		//	POWER_CTL c�me
			read <= 1'b0;					// �r�ssal kezd�nk
		end
		else if (cntr == 18'd249999) begin					// �rajel leoszt�sa
			cntr <= 18'b0;
			if (SCLK) begin										// Lefut� �lre
				if (sclk_cntr == 5'd19) begin					// Ha v�gig �rt�nk egy olvas�s/�r�s cikluson
					if (act_data_cntr == 2'b00) begin		// Az els� ilyen ciklus ut�n...
						measure = 1'b0;							// Measure bit helyett, a Range bitet �ll�tjuk
						range = 1'b1;								// a Range bitet �ll�tjuk
						act_address <= 6'h31;					// DATA_FORMAT c�me
						act_data_cntr <= act_data_cntr + 1'b1;
						end
					else if (act_data_cntr == 2'b01) begin	// A m�sodik ilyen ciklus ut�n...
						measure = 1'b0;							// Mindegyik bemeneti bitet kikapcsoljuk
						range = 1'b0;
						act_address <= 6'h34;					// DATAY0 c�me
						act_data_cntr <= act_data_cntr + 1'b1;
						read <= 1'b1;								// Innent�l folyamatosan csak olvassuk az adatokat
					end
					sclk_cntr <= 5'b0;
				end
				else
					sclk_cntr <= sclk_cntr + 1'b1;
					
				case(sclk_cntr)							// A cikluson bel�li, h�nyadik �rajeln�l tartunk...
					5'd0: nCS <= 1'b1;					// Az SPI eszk�z tiltva
					5'd1: nCS <= 1'b0;					// Az SPI eszk�z enged�lyezve, ciklus indul
					5'd2: begin
								MOSI <= read;				// K�ldj�k a read bitet
								sclk_en <= 1'b0;			// �rajel enged�lyezve
							end
					5'd3: MOSI <= 1'b0; 					// MB-Multi-byte, nem haszn�ljuk
		
					5'd4: MOSI <= act_address[5];		// A haszn�lni k�v�nt regiszter c�me
					5'd5: MOSI <= act_address[4];
					5'd6: MOSI <= act_address[3];
					5'd7: MOSI <= act_address[2];
					5'd8: MOSI <= act_address[1];
					5'd9: MOSI <= act_address[0];
					
					5'd10: MOSI <= 1'b0;					// �r�s�l: POWER_CTL <= 00001000 m�r�s enged�lyez�s�hez
					5'd11: MOSI <= 1'b0;					// majd DATA_FORMAT <= 00000001 4g-s m�r�si tartom�nyhoz
					5'd12: MOSI <= 1'b0;					// olvas�s�n�l viszont csupa nulla
					5'd13: MOSI <= 1'b0;
					5'd14: MOSI <= measure;
					5'd15: MOSI <= 1'b0;
					5'd16: MOSI <= 1'b0;
					5'd17: MOSI <= range;
					
					5'd19: begin
								nCS <= 1'b1;				// A ciklus z�r�sa
								sclk_en <= 1'b1;			// �rajel tilt�sa
							 end
					default: begin							// Minden m�s esetben ugyanez
									nCS <= 1'b0;
									sclk_en <= 1'b0;
								end
				endcase
			end
			else 											// if (~SCLK) => Az olvas�s�t felfut� �lre v�gezz�k
				case (sclk_cntr)
					5'd11: out[7] <= bi && read;	// Ha olvas�s van, a sorosan k�ld�tt adatokat kiolvassuk
					5'd12: out[6] <= bi && read;
					5'd13: out[5] <= bi && read;
					5'd14: out[4] <= bi && read;
					5'd15: out[3] <= bi && read;
					5'd16: out[2] <= bi && read;
					5'd17: out[1] <= bi && read;
					5'd18: out[0] <= bi && read;
				endcase
			SCLK <= ~SCLK;					// F�lperi�dusonk�nt az SCLK bit neg�l�sa => �rajel
		end
		else cntr <= cntr + 1'b1;
	 end
	 
	 // A megfelel� vez�rl�jelek el��ll�t�sa
	 
	 assign bo[0] = nCS;
	 assign bo[1] = MOSI;
	 assign bo[2] = sclk_en || SCLK;
	 
	 assign left = out[7] && (out[6:0] <= 7'd96);
	 assign right = ~out[7] && (out[6:0] >= 7'd32);
	 assign middle = ~(left && right);
 	 
endmodule