`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:09:54 02/21/2014
// Design Name:   Display
// Module Name:   X:/EC551_Project/testclock.v
// Project Name:  EC551_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testclock;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire [2:0] R;
	wire [2:0] G;
	wire [1:0] B;
	wire HS;
	wire VS;
	wire clk_40Mhz;

	// Instantiate the Unit Under Test (UUT)
	Display uut (
		.R(R), 
		.G(G), 
		.B(B), 
		.HS(HS), 
		.VS(VS), 
		.rst(rst), 
		.clk(clk),
		.clk_40Mhz(clk_40Mhz)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        $finish;
		// Add stimulus here

	end
      
		always begin
			clk = ~clk;
			#5;
		end
endmodule

