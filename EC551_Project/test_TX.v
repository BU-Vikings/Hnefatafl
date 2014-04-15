`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   02:23:20 04/15/2014
// Design Name:   UART_Tx
// Module Name:   X:/Desktop/Hnefatafl/EC551_Project/test_TX.v
// Project Name:  EC551_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UART_Tx
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_TX;

	// Inputs
	reg clk;
	reg TxD_start;
	reg [7:0] TxD_data;

	// Outputs
	wire TxD;
	wire TxD_busy;

	// Instantiate the Unit Under Test (UUT)
	UART_Tx uut (
		.clk(clk), 
		.TxD_start(TxD_start), 
		.TxD_data(TxD_data), 
		.TxD(TxD), 
		.TxD_busy(TxD_busy)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		TxD_start = 0;
		TxD_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		TxD_data = 8'b10101010;
		TxD_start = 1'b1;
		#10;
		TxD_start = 1'b0;
		
	end
	
	always begin
		clk = ~clk;
		#5;
	end
      
endmodule

