`timescale 1ns / 1ps

/******************************************/
/*          VGA vez�rl� modul             */
/******************************************/

module VGA(
	input clk,					// 50 MHz-es rendszer �rajel
	input rst,					// Resetelhet�
	input [5:0] data,			// 2*3 rgb adatbit
	output [8:0] io,			// VGA kimeneti portjai
	output [6:0] hor_addr,	// horizont�lis c�m
	output [7:0] ver_addr,	// vertik�lis c�m
	output read,				// olvasunk a mem�ri�b�l (l�that� k�ptartom�ny)
	output write				// �rjuk a mem�ri�t (neml�that� k�ptartom�ny egy r�sz�n)
    );
	 
	 reg [9:0] ver_cntr = 10'd1;		// verti�lisan, a sorok sz�ml�l�s��rt (666 sor => 10 bit)
	 reg [10:0] hor_cntr = 11'd1;		// horizont�lisan, az oszlopok sz�ml�l�s��rt (1040 oszlop => 11 bit)
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin						// Resetre mindegyiket 1-be �ll�tjuk (k�nnyebb majd a k�perny�t tervezni)
			ver_cntr <= 10'd1;
			hor_cntr <= 11'd1;
		end
		else begin
			if (hor_cntr == 11'd1040) begin						// Ha v�gig�rt�nk egy soron, �rt�ke vissza egybe...
				hor_cntr <= 11'd1;
				if (ver_cntr == 10'd666) ver_cntr <= 10'd1;	// Ha az �sszes soron v�gig�rt�nk, vertik�lisan is vissza egybe...
				else ver_cntr <= ver_cntr + 1'b1;				// Egy�bk�nt ugrunk a k�vetkez� sorra
			end
			else hor_cntr <= hor_cntr + 1'b1;					// Egy�bk�nt haladunk tov�bb a soron bel�l
		end
	 end
	 
	 assign visible = ((ver_cntr >= 10'd1) && (ver_cntr <= 10'd600) &&	// L�that� tartom�ny megad�sa
							 (hor_cntr >= 11'd200) && (hor_cntr <= 11'd603));	// vertik�isan: 1-600, horizont�lisan: 200-603,
	 
	 // A l�that� k�ptartom�yt mindk�t oldal szerint negyedelj�k
	 // Ez�rt c�mz�sre az als� ket�tt eldobhatjuk
	 // �r�shoz viszont nem kell osztanunk a c�met
	 // Ez�rt a gyorsabb �r�s �rdek�ben, horizont�lis esetben az als� biteket haszn�ljuk fel c�mz�sre
	 assign hor_addr = visible ? hor_cntr[8:2] : hor_cntr[6:0];
	 assign ver_addr = ver_cntr[9:2];
	 
	 // L�that� k�ptartom�ny alatt enged�lyezz�k az olvas�st
	 assign read = visible;
	 
	 //			10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
	 // 200  =   0   0 | 0   1   1   0   0   1   0 | 0   0	 Olvas�s tartom�nyban:
	 // 603  =   0   1 | 0   0   1   0   1   1   0 | 1   1    hor_cntr[8:2] 50-t�l 22-ig c�mez
	 
	 // 690  =   0   1   0   1 | 0   1   1   0   0   1   0 |	 �r�s tartom�nyban
	 // 790  =   0   1   1   0 | 0   0   1   0   1   1   0 |  hor_cntr[6:0] 50-t�l 22-ig c�mez
	 // A fentiek alapj�n enged�lyezz�k az �r�st
	 assign write = ((ver_cntr >= 10'd1) && (ver_cntr <= 10'd600) &&
						  (hor_cntr >= 11'd690) && (hor_cntr <= 11'd790));
	 
	 assign io[0] = 0;								// PWM audio
	 assign io[1] = visible && data[0];			// VGA piros jel (1.bit)	
	 assign io[2] = visible && data[1];			// VGA piros jel (0.bit)
	 assign io[3] = visible && data[2];			// VGA z�ld jel (1.bit)
	 assign io[4] = visible && data[3];			// VGA z�ld jel (0.bit)
	 assign io[5] = visible && data[4];			// VGA k�k jel (1.bit)
	 assign io[6] = visible && data[5];			// VGA k�k jel (0.bit)
	 assign io[7] = ((ver_cntr <= 10'd643) && (ver_cntr > 10'd637));	// VGA vertik�lis szinkronjel
	 assign io[8] = ((hor_cntr <= 11'd976) && (hor_cntr > 11'd856));	// VGA horizont�lis szinkronjel
	 
endmodule
