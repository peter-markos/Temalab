`timescale 1ns / 1ps

/******************************************/
/*      Accelorometer vezérlõ modul       */
/******************************************/

module Accelo(
	input clk,			// 50 MHz-es rendszerórajel
	input rst,			// Resetelhetõ
	
	output [2:0] bo,	// Accelorometer kimeneti portjai: 2-SCLK, 1-MOSI, 0-nCS
	input bi,			// Accelorometer bemeneti portja: MISO
	
	output right,		// Jobbramozgás jelzése
	output left,		// Balramozgás jelzése
	output middle		// Alaphelyzet jelzése
    );
	 
	 reg MOSI, SCLK, nCS;	// SPI vezérlõ jelek
	 
	 reg [17:0] cntr;			// Órajel osztáshoz számláló. 50 Mhz => 100 Hz 249999 után kell váltani
	 reg [7:0] out;			// A sorosan kapott 8 bites adat eltárolására
	 reg [4:0] sclk_cntr;	//	Egy írási/olvasási ciklusban eltelt órajelperiódusok számolására
	 reg sclk_en;				// Az SPI órajel engedélyezése (negált logika)
	 reg read = 1'b0;			// Olvasás / Írás
	 
	 reg measure = 1'b1;		// POWER_CTL regiszter Measure bitjét 1-be állítani a mérés engedélyezéséhez
	 reg range = 1'b0;		// DATA_FORMAT regiszter-ben a Range-t 01-re állítani a 4g-s mérési tartományhoz
	 reg [5:0] act_address = 6'h2D;	// Az aktuálisan használt regiszter címe
	 reg [1:0] act_data_cntr = 2'b0;	// Számon tartani, hogy hány regisztert kezeltünk
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin						// Resetre minden alaphelyzetbe
			cntr <= 18'b0;
			SCLK <= 1'b0;
			sclk_cntr <= 5'b0;
			sclk_en <= 1'b1;				// Tiltjuk az órajelet
			act_data_cntr <= 2'b0;
			measure = 1'b1;				// Elsõre a POWER_CTL Measure bitjét állítjuk be
			range = 1'b0;
			act_address <= 6'h2D;		//	POWER_CTL címe
			read <= 1'b0;					// Írással kezdünk
		end
		else if (cntr == 18'd249999) begin					// Órajel leosztása
			cntr <= 18'b0;
			if (SCLK) begin										// Lefutó élre
				if (sclk_cntr == 5'd19) begin					// Ha végig értünk egy olvasás/írás cikluson
					if (act_data_cntr == 2'b00) begin		// Az elsõ ilyen ciklus után...
						measure = 1'b0;							// Measure bit helyett, a Range bitet állítjuk
						range = 1'b1;								// a Range bitet állítjuk
						act_address <= 6'h31;					// DATA_FORMAT címe
						act_data_cntr <= act_data_cntr + 1'b1;
						end
					else if (act_data_cntr == 2'b01) begin	// A második ilyen ciklus után...
						measure = 1'b0;							// Mindegyik bemeneti bitet kikapcsoljuk
						range = 1'b0;
						act_address <= 6'h34;					// DATAY0 címe
						act_data_cntr <= act_data_cntr + 1'b1;
						read <= 1'b1;								// Innentõl folyamatosan csak olvassuk az adatokat
					end
					sclk_cntr <= 5'b0;
				end
				else
					sclk_cntr <= sclk_cntr + 1'b1;
					
				case(sclk_cntr)							// A cikluson belüli, hányadik órajelnél tartunk...
					5'd0: nCS <= 1'b1;					// Az SPI eszköz tiltva
					5'd1: nCS <= 1'b0;					// Az SPI eszköz engedélyezve, ciklus indul
					5'd2: begin
								MOSI <= read;				// Küldjük a read bitet
								sclk_en <= 1'b0;			// Órajel engedélyezve
							end
					5'd3: MOSI <= 1'b0; 					// MB-Multi-byte, nem használjuk
		
					5'd4: MOSI <= act_address[5];		// A használni kívánt regiszter címe
					5'd5: MOSI <= act_address[4];
					5'd6: MOSI <= act_address[3];
					5'd7: MOSI <= act_address[2];
					5'd8: MOSI <= act_address[1];
					5'd9: MOSI <= act_address[0];
					
					5'd10: MOSI <= 1'b0;					// Írásál: POWER_CTL <= 00001000 mérés engedélyezéséhez
					5'd11: MOSI <= 1'b0;					// majd DATA_FORMAT <= 00000001 4g-s mérési tartományhoz
					5'd12: MOSI <= 1'b0;					// olvasásánál viszont csupa nulla
					5'd13: MOSI <= 1'b0;
					5'd14: MOSI <= measure;
					5'd15: MOSI <= 1'b0;
					5'd16: MOSI <= 1'b0;
					5'd17: MOSI <= range;
					
					5'd19: begin
								nCS <= 1'b1;				// A ciklus zárása
								sclk_en <= 1'b1;			// Órajel tiltása
							 end
					default: begin							// Minden más esetben ugyanez
									nCS <= 1'b0;
									sclk_en <= 1'b0;
								end
				endcase
			end
			else 											// if (~SCLK) => Az olvasását felfutó élre végezzük
				case (sclk_cntr)
					5'd11: out[7] <= bi && read;	// Ha olvasás van, a sorosan küldött adatokat kiolvassuk
					5'd12: out[6] <= bi && read;
					5'd13: out[5] <= bi && read;
					5'd14: out[4] <= bi && read;
					5'd15: out[3] <= bi && read;
					5'd16: out[2] <= bi && read;
					5'd17: out[1] <= bi && read;
					5'd18: out[0] <= bi && read;
				endcase
			SCLK <= ~SCLK;					// Félperiódusonként az SCLK bit negálása => órajel
		end
		else cntr <= cntr + 1'b1;
	 end
	 
	 // A megfelelõ vezérlõjelek elõállítása
	 
	 assign bo[0] = nCS;
	 assign bo[1] = MOSI;
	 assign bo[2] = sclk_en || SCLK;
	 
	 assign left = out[7] && (out[6:0] <= 7'd96);
	 assign right = ~out[7] && (out[6:0] >= 7'd32);
	 assign middle = ~(left && right);
 	 
endmodule