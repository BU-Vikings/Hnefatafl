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
module Display(R, G, B, HS, VS, rst, clk, read_x, read_y, readData, spriteByte, address_out, tutorial, hx, hy, highlight, mx, my, address_demo, demo_out);

	input rst;	// global reset
	input clk;	// 100MHz clk
	input [7:0] spriteByte;

	output reg [3:0] read_x;
	output reg [3:0] read_y;
	reg [10:0] s_x;
	reg [10:0] s_y;
	output [15:0] address_out;
	output [13:0] address_demo;
	input [1:0] readData;
	input [7:0] demo_out;
	input tutorial;
	input [1:0] highlight;
	input [3:0] hx, hy;
	input [3:0] mx, my;


	
	wire read;

	// color outputs to show on display (current pixel)
	output reg [2:0] R, G;
	output reg [1:0] B;
	
	// Synchronization signals
	output HS;
	output VS;
	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	wire CLKSYS;
	wire CLK_out;
	//dcm_all_v2 test(.CLK(clk), .CLKSYS(CLKSYS), . CLK_out(CLK_out));
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
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank));
	
	parameter screen_width = 464;
	parameter square_width = 42;
	parameter screen_height = 464;
	parameter square_height = 42;
	parameter line_width = 4;
	parameter line_right = line_width / 2;
	parameter line_left = square_width - line_right;
	parameter line_bottom = line_width / 2;
	parameter line_top = square_height - line_bottom;
	parameter sprite_dim = 40;
	
	wire img1;
	
	assign img1 = hcount >= 100 && hcount < 130 && vcount >= 100 && vcount < 130;
	
	wire v_line;
	wire h_line;
	assign v_line = ~blank && hcount < screen_width && vcount < screen_height && (hcount % square_width) <= line_right;
	assign h_line = ~blank && vcount < screen_height && hcount < screen_width && (vcount % square_height) <= line_bottom;
	
	// send colors:
	always @ (posedge clk_25Mhz) begin
	if (tutorial) begin
		if (hcount >= 200 && hcount < 500 && vcount >= 200 && vcount < 230) begin
		R = demo_out[7:5];
		G = demo_out[4:2];
		B = demo_out[1:0];
		end
		else begin
		R = 3'b000;
		G = 3'b000;
		B = 2'b00;
		end	
	end
	
	else begin
	
		if (h_line || v_line) begin	// if you are within the valid region
			R = 3'b111;
			G = 3'b111;
			B = 2'b11;

		end else begin
			if (hcount >= 2 && hcount <= 41) begin
				read_x = 4'b0000;
				s_x = hcount - 2;
			end else if (hcount >= 44 && hcount < 84) begin
				read_x = 4'b0001;
				s_x = hcount - 44;
			end else if (hcount >= 86 && hcount < 126) begin
				read_x = 4'b0010;
				s_x = hcount - 86;
			end else if (hcount >= 128 && hcount < 168) begin
				read_x = 4'b0011;
				s_x = hcount - 128;
			end else if (hcount >= 170 && hcount < 210) begin
				read_x = 4'b0100;
				s_x = hcount - 170;
			end else if (hcount >= 212 && hcount < 252) begin
				read_x = 4'b0101;
				s_x = hcount - 212;
			end else if (hcount >= 254 && hcount < 294) begin
				read_x = 4'b0110;
				s_x = hcount - 254;
			end else if (hcount >= 296 && hcount < 336) begin
				read_x = 4'b0111;
				s_x = hcount - 296;
			end else if (hcount >= 338 && hcount < 378) begin
				read_x = 4'b1000;
				s_x = hcount - 338;
			end else if (hcount >= 380 && hcount < 420) begin
				read_x = 4'b1001;
				s_x = hcount - 380;
			end else if (hcount >= 422 && hcount < 462) begin
				read_x = 4'b1010;
				s_x = hcount - 422;
			end
			if (vcount >= 2 && vcount <= 41) begin
				read_y = 4'b0000;
				s_y = vcount - 2;
			end else if (vcount >= 44 && vcount < 84) begin
				read_y = 4'b0001;
				s_y = vcount - 44;
			end else if (vcount >= 86 && vcount < 126) begin
				read_y = 4'b0010;
				s_y = vcount - 86;
			end else if (vcount >= 128 && vcount < 168) begin
				read_y = 4'b0011;
				s_y = vcount - 128;
			end else if (vcount >= 170 && vcount < 210) begin
				read_y = 4'b0100;
				s_y = vcount - 170;
			end else if (vcount >= 212 && vcount < 252) begin
				read_y = 4'b0101;
				s_y = vcount - 212;
			end else if (vcount >= 254 && vcount < 294) begin
				read_y = 4'b0110;
				s_y = vcount - 254;
			end else if (vcount >= 296 && vcount < 336) begin
				read_y = 4'b0111;
				s_y = vcount - 296;
			end else if (vcount >= 338 && vcount < 378) begin
				read_y = 4'b1000;
				s_y = vcount - 338;
			end else if (vcount >= 380 && vcount < 420) begin
				read_y = 4'b1001;
				s_y = vcount - 380;
			end else if (vcount >= 422 && vcount < 462) begin
				read_y = 4'b1010;
				s_y = vcount - 422;
			end
			
			if (vcount < 462 && hcount < 462 && highlight != 2'b00 && hx == read_x && hy == read_y && (s_x <= 5 || (s_x >= 35 && s_x < 40) || s_y <=5 || (s_y >= 35 && s_y < 40))) begin
				case (highlight)
					2'b01: begin
						R = 3'b111;
						G = 3'b000;
						B = 2'b00;
					end
					2'b10: begin
						R = 3'b000;
						G = 3'b000;
						B = 2'b11;
					end
					default: begin
						R = 3'b000;
						G = 3'b000;
						B = 2'b00;
					end
				endcase
			end else if (vcount < 462 && hcount < 462 && highlight == 2'b10 && mx == read_x && my == read_y && (s_x <= 5 || (s_x >= 35 && s_x < 40) || s_y <=5 || (s_y >= 35 && s_y < 40))) begin
				case (highlight)
					2'b10: begin
						R = 3'b111;
						G = 3'b000;
						B = 2'b00;
					end
					2'b11: begin
						R = 3'b000;
						G = 3'b111;
						B = 2'b00;
					end
				endcase
			end else begin
				if (s_x < sprite_dim && s_y < sprite_dim) begin
					case (readData[1:0])
						2'b00: begin
							R = 3'b0;
							G = 3'b0;
							B = 2'b0;
						end
						default: begin
							R = spriteByte[7:5];
							G = spriteByte[4:2];
							B = spriteByte[1:0];
						end
					endcase
				end else begin
					R = 3'b0;
					G = 3'b0;
					B = 2'b0;
				end
			end
		end
	end
end

	assign address_out = ((s_y) * sprite_dim + (s_x)) + (1600 * (readData-1));
	assign address_demo = (vcount-200)*300 + (hcount-200);
endmodule
