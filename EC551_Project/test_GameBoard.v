`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:00:06 04/06/2014
// Design Name:   GameBoard
// Module Name:   X:/Desktop/Hnefatafl/EC551_Project/test_GameBoard.v
// Project Name:  EC551_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: GameBoard
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_GameBoard;

	// Inputs
	reg [3:0] read_x;
	reg [3:0] read_y;
	reg [3:0] read_x2;
	reg [3:0] read_y2;
	reg [1:0] writeData;
	reg [3:0] write_x;
	reg [3:0] write_y;
	reg write;
	reg clk;
	reg rst;

	// Outputs
	wire [1:0] readData;
	wire [1:0] readData2;

	// Instantiate the Unit Under Test (UUT)
	GameBoard uut (
		.read_x(read_x), 
		.read_y(read_y), 
		.read_x2(read_x2), 
		.read_y2(read_y2), 
		.readData(readData), 
		.readData2(readData2), 
		.writeData(writeData), 
		.write_x(write_x), 
		.write_y(write_y), 
		.write(write), 
		.clk(clk), 
		.rst(rst)
	);

	initial begin
		// Initialize Inputs
		read_x = 0;
		read_y = 0;
		read_x2 = 0;
		read_y2 = 0;
		writeData = 0;
		write_x = 0;
		write_y = 0;
		write = 0;
		clk = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
		read_x2 = 5;
		read_y2 = 5;
		#10;
		read_x = 6;
		read_y = 6;
		#10;
		$finish;

	end
      
endmodule

