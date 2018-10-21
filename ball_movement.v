`timescale 1ns / 1ps

/******************************************/
/*       Labda mozgását leíró modul       */
/******************************************/

module ball_movement(
	input clk,						// 50 Mhz-es rendszer órajel
	input rst,						// Resetelhetõ
	input [1:0] btn,				// Gombok az irányításhoz (bt[1]-bal, bt[0]-jobb)
	output reg [9:0] ver_pos,	// A labda középpontjának vertikális pozíciója (y)
	output reg [6:0] hor_pos	// A labda középpontjának horizontális pozíciója (x)
    );
	 
	 reg [20:0] cntr;					// Idõzítéshez számláló (~20.9 ms-onként frissítjük a pozíciót)
	 reg [1:0] upper_cntr = 2'b0;	// A pattanás csúcsán rövid megállás szimuláálásához
	 reg up;								// Felfelé megy-e, ha nem akkor lefele
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin					// Resetre...
			hor_pos <= 7'd50;			// Alappozícióba
			ver_pos <= 10'd475;
			cntr <= 21'b0;				// Számlálók nullázása
			upper_cntr <= 2'b0;
			up <= 1;						// Kezdõirány a felfelé
		end
		else begin
			cntr <= cntr + 1'b1;
		end
		if (cntr[20] == 1) begin	// (2^20)*20ns = 20.9ms
			cntr <= 21'b0;
			if (up)											// Ha felfelé...
				if (ver_pos <= 10'd175) begin			// Eddig a pozícióig megy fel maximum
					if (upper_cntr == 2'b11) begin	// Itt szimuláljuk a megállást
						upper_cntr <= 2'b0;
						up <= 0;								// A megállás után indulhat lefelé
					end
					else upper_cntr <= upper_cntr + 1'b1;
				end
				else if(ver_pos <= 10'd275) ver_pos <= ver_pos - 10'd4;		// felsõ harmada az útnak => leglassabb
				else if(ver_pos <= 10'd375) ver_pos <= ver_pos - 10'd8;		// középsõ harmad => közepes gyorsaság
				else ver_pos <= ver_pos - 10'd12;									// alsó harmad => leggyorsabb
			else																			// Ha lefelé...
				if (ver_pos >= 10'd475) up <= 1;									// Minimum, azonnal indulunk felfelé
				else if(ver_pos >= 10'd375) ver_pos <= ver_pos + 10'd12;	// alsó harmad => leggyorsabb
				else if(ver_pos >= 10'd275) ver_pos <= ver_pos + 10'd8;	// középsõ harmad => közepes gyorsaság
				else ver_pos <= ver_pos + 10'd4;									// felsõ harmad => leglassabb
			if (btn[1] && ~btn[0] && (hor_pos > 7'd6))  	// Balra mozgás
				hor_pos <= hor_pos - 1'b1;
			if (~btn[1] && btn[0] && (hor_pos < 7'd95))	// Jobbra mozgás
				hor_pos <= hor_pos + 1'b1;
		end
	 end


endmodule
