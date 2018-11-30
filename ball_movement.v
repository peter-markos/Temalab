`timescale 1ns / 1ps

/******************************************/
/*       Labda mozgását leíró modul       */
/******************************************/

module ball_movement(
	input clk,						// 50 Mhz-es rendszer órajel
	input rst,						// Resetelhetõ
	
	input right,					// Jobbramozgás jelzése
	input left,						// Balramozgás jelzése
	input middle,					// Alaphelyzet jelzése
	
	output reg [9:0] ball_ver,	// A labda középpontjának vertikális pozíciója (y)
	output reg [6:0] ball_hor,	// A labda középpontjának horizontális pozíciója (x)
	
	// 4 db platform:
	// platform_ver: platform tetejének középpontjának vertikális pozíciója (y)
	// platform_hor: platform tetejének középpontjának horizontális pozíciója (x)
	// platform_width: platform szélessége
	
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
	
	// A képrõl kilépõ platform:
	
	output reg [7:0] out_platform_ver,
	output reg [6:0] out_platform_hor,
	output reg [5:0] out_platform_width,
	
	output reg over			// Játék vége
    );
	 
	 reg [20:0] cntr;					// Idõzítéshez számláló (~20.9 ms-onként frissítjük a pozíciót)
	 reg [1:0] upper_cntr = 2'b0;	// A pattanás csúcsán rövid megállás szimuláálásához
	 reg up;								// Felfelé megy-e, ha nem akkor lefele
	 
	 reg [19:0] score;				// Pontszám
	 
	 wire [6:0] platform4_hor;		// Az új platform horizontális pozíciója
	 
	 wire [6:0] randout;
	 wire [6:0] max;
	 assign max = 7'd100 - platform3_width - platform3_width - 3'd3; 		// Maximálisan generálható véletlen pozíció
	 
	 random RAND(.clk(clk), .trigger(middle), .max(max), .out(randout));	// Véletlen pozíció generálása
	 
	 assign platform4_hor = randout + platform3_width + 3'd3;				// Ez lesz az új platform pozíciója
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin					// Resetre...
			ball_hor <= 7'd50;		// Alappozícióba
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
			
			over <= 1'b0;				// Még nincs vége
			score <= 20'd0;			// Pontszám
			
			cntr <= 21'b0;				// Számlálók nullázása
			upper_cntr <= 2'b0;
			up <= 1;						// Kezdõirány a felfelé
		end
		else begin
			cntr <= cntr + 1'b1;
		end
		if (cntr[20] == 1) begin	// (2^20)*20ns = 20.9ms
			cntr <= 21'b0;
			if (up) begin				// Ha felfelé...
				if (ball_ver <= {platform0_ver, 2'b00} - 10'd213) begin			// Eddig a pozícióig megy fel maximum
					if (upper_cntr == 2'b11) begin	// Itt szimuláljuk a megállást
						upper_cntr <= 2'b0;
						up <= 0;								// A megállás után indulhat lefelé
					end
					else upper_cntr <= upper_cntr + 1'b1;
				end
				else if(ball_ver <= {platform0_ver, 2'b00} - 10'd181) ball_ver <= ball_ver - 10'd4;		// felsõ harmada az útnak => leglassabb
				else if(ball_ver <= {platform0_ver, 2'b00} - 10'd117) ball_ver <= ball_ver - 10'd8;		// középsõ harmad => közepes gyorsaság
				else ball_ver <= ball_ver - 10'd12;									// alsó harmad => leggyorsabb
				end
			else begin					// Ha lefelé...
				if (ball_ver >= 10'd600) over <= 1;	// Ha eléri a képernyõ alját, játék vége
				else if((ball_ver == {platform1_ver, 2'b00} - 5'd21) && (ball_hor >= platform1_hor - platform1_width - 2'd2) && (ball_hor <= platform1_hor + platform1_width + 2'd2))
				begin													// Ha továbbugrott a következõ platformra
					up <= 1;											// Felfele indul tovább a labda
					score <= score + 1'd1;						// Plusz egy pont
					if (score[19] == 1) over <= 1'b1;		// 2^20 pont után is halál (Ez kivehetõ)
					
					out_platform_ver <= platform0_ver;		//	A platformok indexeit átadjuk egymásnak
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
					
					platform3_ver <= 5'd0;						// A hármas platform kapja a négyesben tárolt új értékeket
					platform3_hor <= platform4_hor;			// A négyes soha nem látszik
					if (score[1] && score[0] && (platform3_width >= 4'd10)) platform3_width <= platform3_width - 1'd1; // 4 pontosával csökken az új platformok szélessége
				end
				else if((ball_ver == {platform0_ver, 2'b00} - 10'd21) && (ball_hor >= platform0_hor - platform0_width - 2'd2) && (ball_hor <= platform0_hor + platform0_width + 2'd2)) up <= 1;									// Minimum, azonnal indulunk felfelé
				else if(ball_ver >= {platform0_ver, 2'b00} - 10'd117) ball_ver <= ball_ver + 10'd12;	// alsó harmad => leggyorsabb
				else if(ball_ver >= {platform0_ver, 2'b00} - 10'd181) ball_ver <= ball_ver + 10'd8;	// középsõ harmad => közepes gyorsaság
				else ball_ver <= ball_ver + 10'd4;									// felsõ harmad => leglassabb
			end
			if (platform0_ver <= 8'd130) begin		// Platformok mozgatása lefelé, az alappozícióig
				if (out_platform_ver <= 10'd150) out_platform_ver <= out_platform_ver + 1'd1;
				platform0_ver <= platform0_ver + 1'd1;
				platform1_ver <= platform1_ver + 1'd1;
				platform2_ver <= platform2_ver + 1'd1;
				if (platform2_ver >= 8'd36) platform3_ver <= platform3_ver + 1'd1;
				
			end
			if (left && (ball_hor > 7'd6))  	// Balra mozgás
				ball_hor <= ball_hor - 1'b1;
			if (right && (ball_hor < 7'd95))	// Jobbra mozgás
				ball_hor <= ball_hor + 1'b1;
		end
	 end


endmodule
