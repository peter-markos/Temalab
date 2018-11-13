`timescale 1ns / 1ps

module SPIcomponent(
		input clk,
		input rst,
		input start,
		input bi,
		
		output [2:0] bo,
		output [9:0] xAxis,
		output [9:0] yAxis,
		output [9:0] zAxis
    );
	 
	 wire nCS, MISO, MOSI, SCLK;
	 assign nCS = bo[0];
	 assign MISO = bi;
	 assign MOSI = bo[1];
	 assign SCLK = bo[2];
	 
	 wire [15:0]  TxBuffer;
    wire [7:0]   RxBuffer;
    wire         done;
    wire         transmit;
	 
	 //-------------------------------------------------------------------------
	 //	Controls SPI Interface, Stores Received Data, and Controls Data to Send
	 //-------------------------------------------------------------------------
	 SPImaster C0(
		.rst(rst),
		.start(start),
		.clk(clk),
		.transmit(transmit),
		.txdata(TxBuffer),
		.rxdata(RxBuffer),
		.done(done),
		.x_axis_data(xAxis),
		.y_axis_data(yAxis),
		.z_axis_data(zAxis)
	 );
		
	 //-------------------------------------------------------------------------
	 //		 Produces Timing Signal, Reads ACL Data, and Writes Data to ACL
	 //-------------------------------------------------------------------------
	 SPIinterface C1(
		.sdi(MISO),
		.sdo(MOSI),
		.rst(rst),
		.clk(clk),
		.sclk(SCLK),
		.txbuffer(TxBuffer),
		.rxbuffer(RxBuffer),
		.done_out(done),
		.transmit(transmit)
	 );
		
	 //-------------------------------------------------------------------------
	 //		 			 	Enables/Disables PmodACL Communication
	 //-------------------------------------------------------------------------
	 slaveSelect C2(
		.clk(clk),
		.ss(nCS),
		.done(done),
		.transmit(transmit),
		.rst(rst)
	 );


endmodule
