`timescale 1ns / 1ps
// io[0] - PWM audio
// io[1] - VGA piros jel (1.bit)
// io[2] - VGA piros jel (0.bit)
// io[3] - VGA zöld jel (1.bit)
// io[4] - VGA zöld jel (0.bit)
// io[5] - VGA kék jel (1.bit)
// io[6] - VGA kék jel (0.bit)
// io[7] - VGA vertikális szinkronjel
// io[8] - VGA horizontális szinkronjel

// 50MHz => 20ns periódusidõ
module VGA(
	input clk,
	input rst,
	input [2:0] bt,
	output [8:0] io
    );
	 
	 reg [10:0] ver_cntr = 11'd0;
	 reg [11:0] hor_cntr = 12'd0;
	 
	 always @ (posedge clk)
	 begin
		if (rst) begin
			ver_cntr <= 11'd0;
			hor_cntr <= 12'd0;
		end
		else begin
			if (hor_cntr == 12'd1040) begin
				hor_cntr <= 12'd0;
				if (ver_cntr == 11'd666) ver_cntr <= 11'd0;
				else ver_cntr <= ver_cntr + 1'b1;
			end
			else hor_cntr <= hor_cntr + 1'b1;
		end
	 end
	 
	 wire visible;
	 assign visible = ((ver_cntr <= 11'd600) && (hor_cntr <= 12'd800) && (ver_cntr > 11'd0) && (hor_cntr > 12'd0));
	 
	 assign io[0] = 0;
	 assign io[1] = (visible && hor_cntr[5]);
	 assign io[2] = (visible && hor_cntr[5]);
	 assign io[3] = (visible && bt[0]);
	 assign io[4] = (visible && bt[1]);
	 assign io[5] = (visible && bt[2]);
	 assign io[6] = (visible && bt[2]);
	 assign io[7] = ((ver_cntr <= 11'd643) && (ver_cntr > 11'd637));
	 assign io[8] = ((hor_cntr <= 12'd976) && (hor_cntr > 12'd856));
	 
endmodule
