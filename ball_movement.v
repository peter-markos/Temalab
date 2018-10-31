`timescale 1ns / 1ps

/******************************************/
/*       Labda mozg�s�t le�r� modul       */
/******************************************/

module ball_movement(
	input clk,								// 50 Mhz-es rendszer �rajel
	input rst,								// Resetelhet�
	input [1:0] btn,						// Gombok az ir�ny�t�shoz (bt[1]-bal, bt[0]-jobb)
	
	output reg [9:0] ball_ver,	// A labda k�z�ppontj�nak vertik�lis poz�ci�ja (y)
	output reg [6:0] ball_hor,	// A labda k�z�ppontj�nak horizont�lis poz�ci�ja (x)
	
	output reg [9:0] platform0_ver,
	output reg [6:0] platform0_hor,
	output reg [5:0] platform0_width,
	
	output reg [9:0] platform1_ver,
	output reg [6:0] platform1_hor,
	output reg [5:0] platform1_width,
	
	output reg [9:0] platform2_ver,
	output reg [6:0] platform2_hor,
	output reg [5:0] platform2_width,
	
	output reg [6:0] platform3_ver,
	output reg [6:0] platform3_hor,
	output reg [5:0] platform3_width,
	
	output reg [9:0] out_platform_ver,
	output reg [6:0] out_platform_hor,
	output reg [5:0] out_platform_width,
	
	output reg over
    );
	 
	 reg [20:0] cntr;					// Id�z�t�shez sz�ml�l� (~20.9 ms-onk�nt friss�tj�k a poz�ci�t)
	 reg [1:0] upper_cntr = 2'b0;	// A pattan�s cs�cs�n r�vid meg�ll�s szimul��l�s�hoz
	 reg up;								// Felfel� megy-e, ha nem akkor lefele
	 
	 wire [6:0] platform4_hor;
	 reg [5:0] platform4_width;
	 
	 wire [6:0] randout;
	 
	 random RAND(.clk(clk), .btn(btn), .max(7'd74), .out(randout));
	 assign platform4_hor = randout + 7'd13;
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin					// Resetre...
			ball_hor <= 7'd50;		// Alappoz�ci�ba
			ball_ver <= 10'd499;
			
			out_platform_width <= 6'd48;
			out_platform_ver <= 10'd520;
			out_platform_hor <= 7'd50;
			
			platform0_width <= 6'd48;
			platform0_ver <= 10'd520;
			platform0_hor <= 7'd50;
			
			platform1_width <= 6'd10;
			platform1_ver <= 10'd376;
			platform1_hor <= 7'd20;
			
			platform2_width <= 6'd10;
			platform2_ver <= 10'd232;
			platform2_hor <= 7'd60;
			
			platform3_width <= 6'd10;
			platform3_ver <= 7'd88;
			platform3_hor <= 7'd13;
			
			platform4_width <= 6'd10;
			
			over <= 0;
			
			cntr <= 21'b0;				// Sz�ml�l�k null�z�sa
			upper_cntr <= 2'b0;
			up <= 1;						// Kezd�ir�ny a felfel�
		end
		else begin
			cntr <= cntr + 1'b1;
		end
		if (cntr[20] == 1) begin	// (2^20)*20ns = 20.9ms
			cntr <= 21'b0;
			if (up) begin											// Ha felfel�...
				if (ball_ver <= platform0_ver - 10'd213) begin			// Eddig a poz�ci�ig megy fel maximum
					if (upper_cntr == 2'b11) begin	// Itt szimul�ljuk a meg�ll�st
						upper_cntr <= 2'b0;
						up <= 0;								// A meg�ll�s ut�n indulhat lefel�
					end
					else upper_cntr <= upper_cntr + 1'b1;
				end
				else if(ball_ver <= platform0_ver - 10'd181) ball_ver <= ball_ver - 10'd4;		// fels� harmada az �tnak => leglassabb
				else if(ball_ver <= platform0_ver - 10'd117) ball_ver <= ball_ver - 10'd8;		// k�z�ps� harmad => k�zepes gyorsas�g
				else ball_ver <= ball_ver - 10'd12;									// als� harmad => leggyorsabb
				end
			else begin																			// Ha lefel�...
				if (ball_ver >= 10'd600) over <= 1;
				else if((ball_ver == platform1_ver - 10'd21) && (ball_hor >= platform1_hor - platform1_width - 2'd2) && (ball_hor <= platform1_hor + platform1_width + 2'd2))
				begin
					up <= 1;
					
					out_platform_ver <= platform0_ver;
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
					
					platform3_ver <= 7'd0;
					platform3_hor <= platform4_hor;
					platform3_width <= platform4_width;
				end
				else if((ball_ver == platform0_ver - 10'd21) && (ball_hor >= platform0_hor - platform0_width - 2'd2) && (ball_hor <= platform0_hor + platform0_width + 2'd2)) up <= 1;									// Minimum, azonnal indulunk felfel�
				else if(ball_ver >= platform0_ver - 10'd117) ball_ver <= ball_ver + 10'd12;	// als� harmad => leggyorsabb
				else if(ball_ver >= platform0_ver - 10'd181) ball_ver <= ball_ver + 10'd8;	// k�z�ps� harmad => k�zepes gyorsas�g
				else ball_ver <= ball_ver + 10'd4;									// fels� harmad => leglassabb
				end
			if (platform0_ver <= 10'd520) begin
				if (out_platform_ver <= 10'd600) out_platform_ver <= out_platform_ver + 10'd4;
				platform0_ver <= platform0_ver + 10'd4;
				platform1_ver <= platform1_ver + 10'd4;
				platform2_ver <= platform2_ver + 10'd4;
				if (platform2_ver >= 10'd144) platform3_ver <= platform3_ver + 7'd4;
				
			end
			if (btn[1] && ~btn[0] && (ball_hor > 7'd6))  	// Balra mozg�s
				ball_hor <= ball_hor - 1'b1;
			if (~btn[1] && btn[0] && (ball_hor < 7'd95))	// Jobbra mozg�s
				ball_hor <= ball_hor + 1'b1;
		end
	 end


endmodule
