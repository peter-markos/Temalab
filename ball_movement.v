`timescale 1ns / 1ps

/******************************************/
/*       Labda mozg�s�t le�r� modul       */
/******************************************/

module ball_movement(
	input clk,						// 50 Mhz-es rendszer �rajel
	input rst,						// Resetelhet�
	
	input right,					// Jobbramozg�s jelz�se
	input left,						// Balramozg�s jelz�se
	input middle,					// Alaphelyzet jelz�se
	
	output reg [9:0] ball_ver,	// A labda k�z�ppontj�nak vertik�lis poz�ci�ja (y)
	output reg [6:0] ball_hor,	// A labda k�z�ppontj�nak horizont�lis poz�ci�ja (x)
	
	// 4 db platform:
	// platform_ver: platform tetej�nek k�z�ppontj�nak vertik�lis poz�ci�ja (y)
	// platform_hor: platform tetej�nek k�z�ppontj�nak horizont�lis poz�ci�ja (x)
	// platform_width: platform sz�less�ge
	
	output reg [7:0] platform0_ver,
	output reg [6:0] platform0_hor,
	output reg [5:0] platform0_width,
	
	output reg [6:0] platform1_ver,
	output reg [6:0] platform1_hor,
	output reg [4:0] platform1_width,
	
	output reg [5:0] platform2_ver,
	output reg [6:0] platform2_hor,
	output reg [4:0] platform2_width,
	
	output reg [4:0] platform3_ver,
	output reg [6:0] platform3_hor,
	output reg [4:0] platform3_width,
	
	// A k�pr�l kil�p� platform:
	
	output reg [7:0] out_platform_ver,
	output reg [6:0] out_platform_hor,
	output reg [5:0] out_platform_width,
	
	output reg over			// J�t�k v�ge
    );
	 
	 reg [20:0] cntr;					// Id�z�t�shez sz�ml�l� (~20.9 ms-onk�nt friss�tj�k a poz�ci�t)
	 reg [1:0] upper_cntr = 2'b0;	// A pattan�s cs�cs�n r�vid meg�ll�s szimul��l�s�hoz
	 reg up;								// Felfel� megy-e, ha nem akkor lefele
	 
	 reg [19:0] score;				// Pontsz�m
	 
	 wire [6:0] platform4_hor;		// Az �j platform horizont�lis poz�ci�ja
	 
	 wire [6:0] randout;
	 wire [6:0] max;
	 assign max = 7'd100 - platform3_width - platform3_width - 3'd3; 		// Maxim�lisan gener�lhat� v�letlen poz�ci�
	 
	 random RAND(.clk(clk), .trigger(middle), .max(max), .out(randout));	// V�letlen poz�ci� gener�l�sa
	 
	 assign platform4_hor = randout + platform3_width + 3'd3;				// Ez lesz az �j platform poz�ci�ja
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin					// Resetre...
			ball_hor <= 7'd50;		// Alappoz�ci�ba
			ball_ver <= 10'd499;
			
			out_platform_width <= 6'd48;
			out_platform_ver <= 8'd130;
			out_platform_hor <= 7'd51;
			
			platform0_width <= 6'd48;
			platform0_ver <= 8'd130;
			platform0_hor <= 7'd51;
			
			platform1_width <= 6'd20;
			platform1_ver <= 7'd94;
			platform1_hor <= 7'd25;
			
			platform2_width <= 6'd20;
			platform2_ver <= 6'd58;
			platform2_hor <= 7'd60;
			
			platform3_width <= 6'd20;
			platform3_ver <= 5'd22;
			platform3_hor <= 7'd30;
			
			over <= 1'b0;				// M�g nincs v�ge
			score <= 20'd0;			// Pontsz�m
			
			cntr <= 21'b0;				// Sz�ml�l�k null�z�sa
			upper_cntr <= 2'b0;
			up <= 1;						// Kezd�ir�ny a felfel�
		end
		else begin
			cntr <= cntr + 1'b1;
		end
		if (cntr[20] == 1) begin	// (2^20)*20ns = 20.9ms
			cntr <= 21'b0;
			if (up) begin				// Ha felfel�...
				if (ball_ver <= {platform0_ver, 2'b00} - 10'd213) begin			// Eddig a poz�ci�ig megy fel maximum
					if (upper_cntr == 2'b11) begin	// Itt szimul�ljuk a meg�ll�st
						upper_cntr <= 2'b0;
						up <= 0;								// A meg�ll�s ut�n indulhat lefel�
					end
					else upper_cntr <= upper_cntr + 1'b1;
				end
				else if(ball_ver <= {platform0_ver, 2'b00} - 10'd181) ball_ver <= ball_ver - 10'd4;		// fels� harmada az �tnak => leglassabb
				else if(ball_ver <= {platform0_ver, 2'b00} - 10'd117) ball_ver <= ball_ver - 10'd8;		// k�z�ps� harmad => k�zepes gyorsas�g
				else ball_ver <= ball_ver - 10'd12;									// als� harmad => leggyorsabb
				end
			else begin					// Ha lefel�...
				if (ball_ver >= 10'd600) over <= 1;	// Ha el�ri a k�perny� alj�t, j�t�k v�ge
				else if((ball_ver == {platform1_ver, 2'b00} - 5'd21) && (ball_hor >= platform1_hor - platform1_width - 2'd2) && (ball_hor <= platform1_hor + platform1_width + 2'd2))
				begin													// Ha tov�bbugrott a k�vetkez� platformra
					up <= 1;											// Felfele indul tov�bb a labda
					score <= score + 1'd1;						// Plusz egy pont
					if (score[19] == 1) over <= 1'b1;		// 2^20 pont ut�n is hal�l (Ez kivehet�)
					
					out_platform_ver <= platform0_ver;		//	A platformok indexeit �tadjuk egym�snak
					out_platform_hor <= platform0_hor;
					out_platform_width <= platform0_width;
					
					platform0_ver <= platform1_ver;
					platform0_hor <= platform1_hor;
					platform0_width <= platform1_width;
					
					platform1_ver <= platform2_ver;
					platform1_hor <= platform2_hor;
					platform1_width <= platform2_width;
					
					platform2_ver <= platform3_ver;
					platform2_hor <= platform3_hor;
					platform2_width <= platform3_width;
					
					platform3_ver <= 5'd0;						// A h�rmas platform kapja a n�gyesben t�rolt �j �rt�keket
					platform3_hor <= platform4_hor;			// A n�gyes soha nem l�tszik
					if (score[1] && score[0] && (platform3_width >= 4'd10)) platform3_width <= platform3_width - 1'd1; // 4 pontos�val cs�kken az �j platformok sz�less�ge
				end
				else if((ball_ver == {platform0_ver, 2'b00} - 10'd21) && (ball_hor >= platform0_hor - platform0_width - 2'd2) && (ball_hor <= platform0_hor + platform0_width + 2'd2)) up <= 1;									// Minimum, azonnal indulunk felfel�
				else if(ball_ver >= {platform0_ver, 2'b00} - 10'd117) ball_ver <= ball_ver + 10'd12;	// als� harmad => leggyorsabb
				else if(ball_ver >= {platform0_ver, 2'b00} - 10'd181) ball_ver <= ball_ver + 10'd8;	// k�z�ps� harmad => k�zepes gyorsas�g
				else ball_ver <= ball_ver + 10'd4;									// fels� harmad => leglassabb
			end
			if (platform0_ver <= 8'd130) begin		// Platformok mozgat�sa lefel�, az alappoz�ci�ig
				if (out_platform_ver <= 10'd150) out_platform_ver <= out_platform_ver + 1'd1;
				platform0_ver <= platform0_ver + 1'd1;
				platform1_ver <= platform1_ver + 1'd1;
				platform2_ver <= platform2_ver + 1'd1;
				if (platform2_ver >= 8'd36) platform3_ver <= platform3_ver + 1'd1;
				
			end
			if (left && (ball_hor > 7'd6))  	// Balra mozg�s
				ball_hor <= ball_hor - 1'b1;
			if (right && (ball_hor < 7'd95))	// Jobbra mozg�s
				ball_hor <= ball_hor + 1'b1;
		end
	 end


endmodule
