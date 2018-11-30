`timescale 1ns / 1ps

/******************************************/
/*        V�letlen sz�m gener�tor         */
/******************************************/

module random(
	input [6:0] max,							// Max �rt�k, amit m�g kiadhat
	input trigger,								// Mintav�tel jelz�se
	input clk,									// 50 MHz-es rendszer�rajel
	
	output reg [6:0] out						// Eredm�ny
    );
	 
	 reg [6:0] cntr = 7'b0;					// Sz�ml�l�
	 
	 always @ (posedge clk)
	 begin
		if (cntr == max) cntr <= 7'b0;	// Max ut�n �jraindul
		else cntr <= cntr + 1'b1;			// am�gy folyamatosan sz�mol felfel�
		if (trigger) out <= cntr;			// Trigger jelz�sre kimenti, a sz�ml�l� aktu�lis �rt�k�t, a kimenetre
	 end

endmodule
