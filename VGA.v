`timescale 1ns / 1ps

/******************************************/
/*          VGA vezérlõ modul             */
/******************************************/

module VGA(
	input clk,					// 50 MHz-es rendszer órajel
	input rst,					// Resetelhetõ
	input [5:0] data,			// 2*3 rgb adatbit
	output [8:0] io,			// VGA kimeneti portjai
	output [6:0] hor_addr,	// horizontális cím
	output [7:0] ver_addr,	// vertikális cím
	output read,				// olvasunk a memóriából (látható képtartomány)
	output write				// írjuk a memóriát (nemlátható képtartomány egy részén)
    );
	 
	 reg [9:0] ver_cntr = 10'd1;		// vertiálisan, a sorok számlálásáért (666 sor => 10 bit)
	 reg [10:0] hor_cntr = 11'd1;		// horizontálisan, az oszlopok számlálásáért (1040 oszlop => 11 bit)
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin						// Resetre mindegyiket 1-be állítjuk (könnyebb majd a képernyõt tervezni)
			ver_cntr <= 10'd1;
			hor_cntr <= 11'd1;
		end
		else begin
			if (hor_cntr == 11'd1040) begin						// Ha végigértünk egy soron, értéke vissza egybe...
				hor_cntr <= 11'd1;
				if (ver_cntr == 10'd666) ver_cntr <= 10'd1;	// Ha az összes soron végigértünk, vertikálisan is vissza egybe...
				else ver_cntr <= ver_cntr + 1'b1;				// Egyébként ugrunk a következõ sorra
			end
			else hor_cntr <= hor_cntr + 1'b1;					// Egyébként haladunk tovább a soron belül
		end
	 end
	 
	 assign visible = ((ver_cntr >= 10'd1) && (ver_cntr <= 10'd600) &&	// Látható tartomány megadása
							 (hor_cntr >= 11'd200) && (hor_cntr <= 11'd603));	// vertikáisan: 1-600, horizontálisan: 200-603,
	 
	 // A látható képtartomáyt mindkét oldal szerint negyedeljük
	 // Ezért címzésre az alsó ketõtt eldobhatjuk
	 // Íráshoz viszont nem kell osztanunk a címet
	 // Ezért a gyorsabb írás érdekében, horizontális esetben az alsó biteket használjuk fel címzésre
	 assign hor_addr = visible ? hor_cntr[8:2] : hor_cntr[6:0];
	 assign ver_addr = ver_cntr[9:2];
	 
	 // Látható képtartomány alatt engedélyezzük az olvasást
	 assign read = visible;
	 
	 //			10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
	 // 200  =   0   0 | 0   1   1   0   0   1   0 | 0   0	 Olvasás tartományban:
	 // 603  =   0   1 | 0   0   1   0   1   1   0 | 1   1    hor_cntr[8:2] 50-tõl 22-ig címez
	 
	 // 690  =   0   1   0   1 | 0   1   1   0   0   1   0 |	 Írás tartományban
	 // 790  =   0   1   1   0 | 0   0   1   0   1   1   0 |  hor_cntr[6:0] 50-tõl 22-ig címez
	 // A fentiek alapján engedélyezzük az írást
	 assign write = ((ver_cntr >= 10'd1) && (ver_cntr <= 10'd600) &&
						  (hor_cntr >= 11'd690) && (hor_cntr <= 11'd790));
	 
	 assign io[0] = 0;								// PWM audio
	 assign io[1] = visible && data[0];			// VGA piros jel (1.bit)	
	 assign io[2] = visible && data[1];			// VGA piros jel (0.bit)
	 assign io[3] = visible && data[2];			// VGA zöld jel (1.bit)
	 assign io[4] = visible && data[3];			// VGA zöld jel (0.bit)
	 assign io[5] = visible && data[4];			// VGA kék jel (1.bit)
	 assign io[6] = visible && data[5];			// VGA kék jel (0.bit)
	 assign io[7] = ((ver_cntr <= 10'd643) && (ver_cntr > 10'd637));	// VGA vertikális szinkronjel
	 assign io[8] = ((hor_cntr <= 11'd976) && (hor_cntr > 11'd856));	// VGA horizontális szinkronjel
	 
endmodule
