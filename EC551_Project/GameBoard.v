`timescale 1ns / 1ps


module GameBoard (output throne_empty, input [3:0] read_x, input [3:0] read_y, input [3:0] read_x2, input [3:0] read_y2, output [1:0] readData, output [1:0] readData2, input [1:0] writeData, input [3:0] write_x, input [3:0] write_y, input write, input clk, input rst);
	
	reg [1:0] board_rows [10:0][10:0];
	reg [1:0] writeData_next;
	wire write_edge;
			
	PosedgeDetector wr(.clk(clk), .signal(write), .edgeout(write_edge));
	
	
	assign readData = board_rows[read_x][read_y];
	assign readData2 = board_rows[read_x2][read_y2];
	assign throne_empty = (board_rows[5][5] == 2'b00 ? 1'b1 : 1'b0);
	
	always @ (*) begin
		writeData_next = writeData;
	end

	integer i;
	integer j;
	
	always @ (posedge clk) begin
		if (write_edge) begin
			board_rows[write_x][write_y] <= writeData_next;
		end
	end

integer x;
integer y;
initial begin : INIT_GAME

for (x=0; x<=10; x=x+1) begin
	for (y=0; y<=10; y=y+1) begin
		board_rows[x][y] = 2'b00;
	end
end
	// This is where the black pieces go
	board_rows[3][0] = 2'b01;
	board_rows[4][0] = 2'b01;
	board_rows[5][0] = 2'b01;
	board_rows[6][0] = 2'b01;
	board_rows[7][0] = 2'b01;
	board_rows[5][1] = 2'b01;
	
	board_rows[0][3] = 2'b01;
	board_rows[0][4] = 2'b01;
	board_rows[0][5] = 2'b01;
	board_rows[0][6] = 2'b01;
	board_rows[0][7] = 2'b01;
	board_rows[1][5] = 2'b01;
	
	board_rows[3][10] = 2'b01;
	board_rows[4][10] = 2'b01;
	board_rows[5][10] = 2'b01;
	board_rows[6][10] = 2'b01;
	board_rows[7][10] = 2'b01;
	board_rows[5][9] = 2'b01;
	
	board_rows[10][3] = 2'b01;
	board_rows[10][4] = 2'b01;
	board_rows[10][5] = 2'b01;
	board_rows[10][6] = 2'b01;
	board_rows[10][7] = 2'b01;
	board_rows[9][5] = 2'b01;
	
	// This is where the white pieces go
	board_rows[5][3] = 2'b10;
	
	board_rows[4][4] = 2'b10;
	board_rows[5][4] = 2'b10;
	board_rows[6][4] = 2'b10;
	
	board_rows[3][5] = 2'b10;
	board_rows[4][5] = 2'b10;
	board_rows[6][5] = 2'b10;
	board_rows[7][5] = 2'b10;
	
	board_rows[4][6] = 2'b10;
	board_rows[5][6] = 2'b10;
	board_rows[6][6] = 2'b10;
	
	board_rows[5][7] = 2'b10;
	
	// This is where the king goes
	board_rows[2][5] = 2'b11;
	
end

endmodule
