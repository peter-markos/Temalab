`timescale 1ns / 1ps

/******************************************/
/*       Labda mozg�s�t le�r� modul       */
/******************************************/

module ball_movement(
	input clk,						// 50 Mhz-es rendszer �rajel
	input rst,						// Resetelhet�
	input [1:0] btn,				// Gombok az ir�ny�t�shoz (bt[1]-bal, bt[0]-jobb)
	output reg [9:0] ver_pos,	// A labda k�z�ppontj�nak vertik�lis poz�ci�ja (y)
	output reg [6:0] hor_pos	// A labda k�z�ppontj�nak horizont�lis poz�ci�ja (x)
    );
	 
	 reg [20:0] cntr;					// Id�z�t�shez sz�ml�l� (~20.9 ms-onk�nt friss�tj�k a poz�ci�t)
	 reg [1:0] upper_cntr = 2'b0;	// A pattan�s cs�cs�n r�vid meg�ll�s szimul��l�s�hoz
	 reg up;								// Felfel� megy-e, ha nem akkor lefele
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin					// Resetre...
			hor_pos <= 7'd50;			// Alappoz�ci�ba
			ver_pos <= 10'd475;
			cntr <= 21'b0;				// Sz�ml�l�k null�z�sa
			upper_cntr <= 2'b0;
			up <= 1;						// Kezd�ir�ny a felfel�
		end
		else begin
			cntr <= cntr + 1'b1;
		end
		if (cntr[20] == 1) begin	// (2^20)*20ns = 20.9ms
			cntr <= 21'b0;
			if (up)											// Ha felfel�...
				if (ver_pos <= 10'd175) begin			// Eddig a poz�ci�ig megy fel maximum
					if (upper_cntr == 2'b11) begin	// Itt szimul�ljuk a meg�ll�st
						upper_cntr <= 2'b0;
						up <= 0;								// A meg�ll�s ut�n indulhat lefel�
					end
					else upper_cntr <= upper_cntr + 1'b1;
				end
				else if(ver_pos <= 10'd275) ver_pos <= ver_pos - 10'd4;		// fels� harmada az �tnak => leglassabb
				else if(ver_pos <= 10'd375) ver_pos <= ver_pos - 10'd8;		// k�z�ps� harmad => k�zepes gyorsas�g
				else ver_pos <= ver_pos - 10'd12;									// als� harmad => leggyorsabb
			else																			// Ha lefel�...
				if (ver_pos >= 10'd475) up <= 1;									// Minimum, azonnal indulunk felfel�
				else if(ver_pos >= 10'd375) ver_pos <= ver_pos + 10'd12;	// als� harmad => leggyorsabb
				else if(ver_pos >= 10'd275) ver_pos <= ver_pos + 10'd8;	// k�z�ps� harmad => k�zepes gyorsas�g
				else ver_pos <= ver_pos + 10'd4;									// fels� harmad => leglassabb
			if (btn[1] && ~btn[0] && (hor_pos > 7'd6))  	// Balra mozg�s
				hor_pos <= hor_pos - 1'b1;
			if (~btn[1] && btn[0] && (hor_pos < 7'd95))	// Jobbra mozg�s
				hor_pos <= hor_pos + 1'b1;
		end
	 end


endmodule
