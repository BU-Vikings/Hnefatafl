`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University
// Engineer: Zafar M. Takhirov
// 
// Create Date:    12:59:40 04/12/2011 
// Design Name: EC311 Support Files
// Module Name:    vga_display 
// Project Name: Lab5 / Lab6 / Project
// Target Devices: xc6slx16-3csg324
// Tool versions: XILINX ISE 13.3
// Description: 
//
// Dependencies: vga_controller_640_60
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Display(R, G, B, HS, VS, rst, clk, GameBoard);

	input rst;	// global reset
	input clk;	// 100MHz clk
	input GameBoard; 
	// color outputs to show on display (current pixel)
	output reg [2:0] R, G;
	output reg [1:0] B;
	
	// Synchronization signals
	output HS;
	output VS;
	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank

	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
	
	// Call driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank));
	
	parameter screen_width = 640;
	parameter square_width = screen_width / 11;
	parameter screen_height = 480;
	parameter square_height = screen_height / 11;
	parameter line_width = 2;
	parameter line_right = line_width / 2;
	parameter line_left = square_width - line_right;
	parameter line_bottom = line_width / 2;
	parameter line_top = square_height - line_bottom;
	
	wire v_line;
	wire h_line;
	assign v_line = ~blank & (hcount % square_width) <= line_right || (hcount % square_width) >= line_left;
	assign h_line = ~blank & (vcount % square_height) <= line_bottom || (vcount % square_height) >= line_top;
	
	// send colors:
	always @ (posedge clk) begin
		if (h_line || v_line) begin	// if you are within the valid region
			R = 3'b111;
			G = 3'b111;
			B = 2'b11;
		end
		else begin	// if you are outside the valid region
			R = 3'b0;
			G = 3'b0;
			B = 2'b0;
		end
	end

endmodule
