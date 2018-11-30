`timescale 1ns / 1ps

/******************************************/
/*        Véletlen szám generátor         */
/******************************************/

module random(
	input [6:0] max,							// Max érték, amit még kiadhat
	input trigger,								// Mintavétel jelzése
	input clk,									// 50 MHz-es rendszerórajel
	
	output reg [6:0] out						// Eredmény
    );
	 
	 reg [6:0] cntr = 7'b0;					// Számláló
	 
	 always @ (posedge clk)
	 begin
		if (cntr == max) cntr <= 7'b0;	// Max után újraindul
		else cntr <= cntr + 1'b1;			// amúgy folyamatosan számol felfelé
		if (trigger) out <= cntr;			// Trigger jelzésre kimenti, a számláló aktuális értékét, a kimenetre
	 end

endmodule
