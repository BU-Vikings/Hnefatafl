`timescale 1ns / 1ps

module Control(output [2:0] R, output [2:0] G, output [1:0] B, output HS, output VS, input rst, input clk, input wire data, input wire keybdclk, output reg [7:0] led, input i_TX, output TxD);

parameter BOARD_WIDTH = 11;
parameter BOARD_HEIGHT = 11;
parameter gameclk_hz = 100;

wire gameclk;
wire [1:0] readData;
wire [3:0] read_x;
reg [3:0] read_x2;
reg [3:0] read_y2;
wire [1:0] readData2;
reg [3:0] write_x;
wire [3:0] read_y;
reg [3:0] write_y;
reg [1:0] writeData;
reg write;
wire [241:0] board_squares;
wire [7:0] spriteByte;
wire [15:0] address_out;
wire [13:0] address_demo;
wire [7:0] demo_out;
	wire done;
	wire [7:0] recvd;
reg tutorial = 1'b1;
reg [1:0] highlight = 2'b00;
reg [1:0] new_highlight = 2'b00;
reg [3:0] hx = 5;
reg [3:0] hy = 5;
reg [3:0] new_hx;
reg [3:0] new_hy;
reg [3:0] b = 4'h1;
reg [7:0] data_curr = 8'hf0;
reg [7:0] data_pre = 8'hf0; 
reg flag = 1'b0;
reg [3:0] new_mx;
reg [3:0] new_my;
reg [3:0] mx;
reg [3:0] my;
reg [3:0] new_read_x;
reg [3:0] new_read_y;
reg [3:0] next_offset_x;
reg [3:0] next_offset_y;
reg [3:0] offset_x;
reg [3:0] offset_y;
reg [3:0] new_cx;
reg [3:0] new_cy;
reg [3:0] cx;
reg [3:0] cy;
reg [3:0] vx;
reg [3:0] vy;
reg [3:0] next_vx;
reg [3:0] next_vy;
reg [7:0] next_led;
reg next_write = 1'b0;
reg [1:0] swap_piece;
reg [1:0] next_swap_piece;
reg [1:0] next_writeData;
reg [3:0] next_write_x;
reg [3:0] next_write_y;
reg [1:0] vtype;
reg [1:0] next_vtype;
reg TX_start;
reg [7:0] TX_data = 70;
wire TxD_busy;
reg safe_flag = 1'b1;
reg next_safe_flag = 1'b1;
GameClockDivider gc (.clk_in(clk), .clk_out(gameclk));
GameBoard gb(.clk(clk), .rst(rst), .throne_empty(throne_empty), .read_x(read_x), .read_y(read_y), .read_x2(read_x2), .read_y2(read_y2), .readData(readData), .readData2(readData2), .write_x(write_x), .write_y(write_y), .write(write), .writeData(writeData));
DemoSprites M1(clk,address_out,spriteByte);
Demo D(clk,address_demo,demo_out);
Display (.R(R), .G(G), .B(B), .HS(HS), .VS(VS), .rst(rst), .clk(clk), .read_x(read_x), .read_y(read_y), .readData(readData), .spriteByte(spriteByte), .address_out(address_out), .tutorial(tutorial), .hx(hx), .hy(hy), .highlight(highlight), .mx(mx), .my(my), .address_demo(address_demo), .demo_out(demo_out));
UART_Rx Rx(recvd, i_TX, clk, rst, done);
UART_Tx Tx(.clk(clk), .TxD_start(TX_start), .TxD_data(TX_data), .TxD(TxD), .TxD_busy(TxD_busy));



reg turn = 1'b0; //white 0, black 1
reg next_turn = 1'b1;
reg [5:0] state = 4'b0;
reg [7:0] TX_data_next;
reg TX_start_next = 1'b0;
reg [5:0] next_state = 4'b0;
reg sentinel = 1'b0;
wire flagedge;

PosedgeDetector ped(.clk(clk), .signal(flag), .edgeout(flagedge));



always @(negedge keybdclk) begin 
	case(b)
		1:; //first bit 
		2:data_curr[0]<=data; 
		3:data_curr[1]<=data; 
		4:data_curr[2]<=data; 
		5:data_curr[3]<=data; 
		6:data_curr[4]<=data; 
		7:data_curr[5]<=data; 
		8:data_curr[6]<=data; 
		9:data_curr[7]<=data;
		10: begin
			if (sentinel == 1'b0) begin
				if (data_curr == 8'hf0) begin
					sentinel <= 1'b1;
				end else begin
					sentinel <= 1'b0;
				end
			end else begin
				sentinel <= 1'b0;
				flag<=1'b1; //Parity bit
			end
		end
		11:flag<=1'b0; //Ending bit 		
	endcase 

	if(b<=10) 
		b<=b+1; 
	else if(b==11) 
		b<=1; 

end	
 
always @ (posedge clk) begin
	state <= next_state;
	led <= next_led;
	if (flagedge == 1'b1) begin
		data_pre <= data_curr;
	end else begin
		data_pre <= 8'b0;
	end
	hx <= new_hx;
	hy <= new_hy;
	highlight <= new_highlight;
	mx <= new_mx;
	my <= new_my;
	read_x2 <= new_read_x;
	read_y2 <= new_read_y;
	offset_x <= next_offset_x;
	offset_y <= next_offset_y;
	cx <= new_cx;
	cy <= new_cy;
	swap_piece <= next_swap_piece;
	writeData <= next_writeData;
	write_x <= next_write_x;
	write_y <= next_write_y;
	write <= next_write;
	turn <= next_turn;
	vx <= next_vx;
	vy <= next_vy;
	vtype <= next_vtype;
	safe_flag <= next_safe_flag;
	TX_data <= TX_data_next;
	TX_start <= TX_start_next;
end

parameter PIECE_WHITE = 2'b10;
parameter PIECE_KING = 2'b11;
parameter PIECE_BLACK = 2'b01;
parameter PIECE_BLANK = 2'b00;

always @ (*) begin
	next_state = state;
	new_highlight = highlight;
	new_hx = hx;
	new_hy = hy;
	new_mx = mx;
	new_my = my;
	new_cx = cx;
	new_cy = cy;
	next_led = state;
	new_read_x = read_x2;
	new_read_y = read_y2;
	next_offset_x = offset_x;
	next_offset_y = offset_y;
	next_write = 1'b0;
	next_swap_piece = swap_piece;
	next_writeData = writeData;
	next_write = 1'b0;
	next_write_x = write_x;
	next_write_y = write_y;
	next_turn = turn;
	next_vx = vx;
	next_vy = vy;
	next_vtype = vtype;
	next_safe_flag = safe_flag;
	TX_data_next = TX_data;
	TX_start_next = TX_start;
	case (state)
		4'b0000: begin //wait for tutorial to end on enter
			if (data_pre == 8'b01011010) begin //enter
				next_state = 4'b0001; // goto square select
				tutorial = 1'b0;
			end
		end
		4'b0001: begin //process square selection
			new_highlight = 2'b01; //red
			if (data_pre == 8'b01101011) begin //left
				if (hx >= 1) begin
					new_hx = hx - 1;
				end
			end else if (data_pre == 8'b01110100) begin //right
				if (hx <= 9) begin
					new_hx = hx + 1;
				end
			end else if (data_pre == 8'b01110101) begin //up
				if (hy >= 1) begin
					new_hy = hy - 1;
				end
			end else if (data_pre == 8'b01110010) begin //down
				if (hy <= 9) begin
					new_hy = hy + 1;
				end
			end else if (data_pre == 8'b01011010) begin //enter
				new_mx = hx;
				new_my = hy;
				new_read_x = hx;
				new_read_y = hy;
				next_state = 4'b0010; // goto piece check
			end
		end
		4'b0010: begin //check if the square selected contains a piece belonging to the player whose turn it is
			if ((turn == 1'b0 && (readData2 == PIECE_WHITE || readData2 == PIECE_KING)) || (turn == 1'b1 && (readData2 == PIECE_BLACK))) begin
				next_state = 4'b0011; // goto move select
				next_swap_piece = readData2;
			end else begin
				next_state = 3'b0001; // goto piece select
			end
		end
		4'b0011: begin // 
			new_highlight = 2'b10; //blue/red
			if (data_pre == 8'b01101011) begin //left
				if (mx >= 1) begin
						new_mx = mx - 1;
				end
			end else if (data_pre == 8'b01110100) begin //right
				if (mx <= 9) begin
					new_mx = mx + 1;
				end
			end else if (data_pre == 8'b01110101) begin //up
				if (my >= 1) begin
					new_my = my - 1;
				end
			end else if (data_pre == 8'b01110010) begin //down
				if (my <= 9) begin
					new_my = my + 1;
				end
			end else if (data_pre == 8'b01011010) begin //enter
				next_state = 4'b0100;
			end else if (data_pre == 8'b01110110) begin
				new_highlight = 2'b01;
				next_state = 4'b0001;
			end
		end
		4'b0100: begin
			if ((mx == hx && my == hy) || (mx != hx && my != hy) || (next_swap_piece != PIECE_KING && ((mx == 0 && my == 0) || (mx == 10 && my == 0) || (mx == 0 && my == 10) || (mx == 10 && my == 10) || (mx == 5 && my == 5)))) begin
				next_state = 4'b0011;
			end else begin
				if (mx < hx) begin
					next_offset_x = -1;
				end else if (mx > hx) begin
					next_offset_x = 1;
				end else begin
					next_offset_x = 0;
				end
				if (my < hy) begin
					next_offset_y = -1;
				end else if (my > hy) begin
					next_offset_y = 1;
				end else begin
					next_offset_y = 0;
				end
				new_cx = hx + next_offset_x;
				new_cy = hy + next_offset_y;
				new_read_x = new_cx;
				new_read_y = new_cy;
				next_led = {hx, cx};
				next_state = 4'b0101;
			end
		end
		4'b0101: begin
			next_led = {offset_x, offset_y, 4'b0};
			if (cx == mx && cy == my) begin
				if (readData2 == PIECE_BLANK) begin
					next_state = 4'b0110;
				end else begin
					next_state = 4'b0011;
				end
			end else if (readData2 != PIECE_BLANK) begin
				next_state = 4'b0011;
				next_led = {readData2, cy, offset_y[1:0]};
			end else begin
				new_cx = cx + offset_x;
				new_cy = cy + offset_y;
				new_read_x = new_cx;
				new_read_y = new_cy;
				next_state = 4'b0101;
			end
		end
		4'b0110: begin
			next_led = {readData2, cy, offset_y};
			new_highlight = 2'b11;
			next_writeData = swap_piece;
			next_write = 1'b1;
			next_write_x = mx;
			next_write_y = my;
			next_state = 4'b0111;
		end
		4'b0111: begin
			next_write = 1'b0;
			next_write_x = hx;
			next_write_y = hy;
			next_state = 4'b1000;
			next_writeData = 2'b00;
		end
		4'b1000: begin
			next_write = 1'b1;
			next_state = 4'b1001;
		end
		4'b1001: begin
			new_highlight = 1'b0;
			next_write = 1'b0;
			next_state = 5'b11111;//4'b1010; 
		end
		4'b1010: begin //begin board clean-up
			next_vx = 0;
			next_vy = 0;
			new_read_x = next_vx;
			new_read_y = next_vy;
			next_state = 4'b1011;
		end
		4'b1011: begin
			if (readData2 != PIECE_BLANK) begin
				if (readData2 == PIECE_KING) begin
					if ((vx == 0 && vy == 0) || (vx == 10 && vy == 0) || (vx == 0 && vy == 10) || (vx == 10 && vy == 10)) begin
						next_state = 4'b1101;
					end else begin
						if (vx <= 9) begin
							new_read_x = vx + 1;
							new_read_y = vy;
							next_state = 4'b1110;
						end else begin
							next_state = 4'b1111;
						end
					end
				end else begin
					//not king
					if ((readData2 == PIECE_WHITE && turn == 1'b0) || (readData2 == PIECE_BLACK && turn == 1'b1)) begin
						next_state = 4'b1100;
					end else begin
						new_read_x = vx + 1;
						new_read_y = vy;
						next_vtype = readData2;
						next_state = 5'b10111; //temporary
					end
				end
			end else begin
				next_state = 4'b1100;
			end
		end
		4'b1100: begin
			if (vx == 10 && vy == 10) begin
				next_state = 5'b11110; //change this to exit point
			end else begin
				if (next_vx <= 9) begin
					next_vx = vx + 1;
				end else begin
					next_vx = 0;
					next_vy = vy + 1;
				end
				new_read_x = next_vx;
				new_read_y = next_vy;
				next_state = 4'b1011;
			end
		end
		4'b1101: begin
			//game over -- white wins
		end
		4'b1110: begin
			if (readData2 == PIECE_BLACK || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 10)) begin
				next_state = 4'b1111;
			end else begin
				next_state = 5'b10000;
			end
		end
		4'b1111: begin
			if (vx >= 1) begin
				new_read_x = vx - 1;
				next_state = 5'b10001;
			end else begin
				next_state = 5'b10010;
			end
		end
		5'b10001: begin
			if (readData2 == PIECE_BLACK || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 10)) begin
				next_state = 5'b10010;
			end else begin
				next_state = 5'b10000;
			end
		end
		5'b10000: begin
			//king is safe
			next_state = 4'b1100;
		end
		5'b10010: begin
			if (vy >= 1) begin
				new_read_x = vx;
				new_read_y = vy - 1;
				next_state = 5'b10011;
			end else begin
				next_state = 5'b10100;
			end
		end
		5'b10011: begin
			if (readData2 == PIECE_BLACK || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 10)) begin
				next_state = 5'b10100;
			end else begin
				next_state = 5'b10000;
			end
		end
		5'b10100: begin
			if (vy <= 9) begin
				new_read_y = vy + 1;
				next_state = 5'b10101;
			end else begin
				next_state = 5'b10110;
			end
		end
		5'b10101: begin
			if (readData2 == PIECE_BLACK || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 10)) begin
				next_state = 5'b10110;
			end else begin
				next_state = 5'b10000;
			end
		end
		5'b10110: begin
			//black wins -- king surrounded
		end
		5'b10111: begin
			if ((vtype[1] == 1'b1 && throne_empty == 1'b1 && read_x2 == 5 && read_y2 == 5) || (vtype == PIECE_BLACK && read_x2 == 5 && read_y2 == 5) || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 10) || (vtype == PIECE_BLACK && readData2[1] == 1'b1) || (vtype == PIECE_WHITE && readData2 == PIECE_BLACK)) begin //readData2[1] == 1'b1 ---> white or king
				new_read_x = vx - 1;
				next_state = 5'b11000;
				if (read_x2 == mx && read_y2 == my) begin
					next_safe_flag = 1'b0;
				end
			end else begin
				new_read_x = vx;
				new_read_y = vy + 1;
				next_state = 5'b11001;
			end
		end
		5'b11000: begin
			if ((vtype[1] == 1'b1 && throne_empty == 1'b1 && read_x2 == 5 && read_y2 == 5) || (vtype == PIECE_BLACK && read_x2 == 5 && read_y2 == 5) || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 10) || (vtype == PIECE_BLACK && readData2[1] == 1'b1) || (vtype == PIECE_WHITE && readData2 == PIECE_BLACK)) begin //readData2[1] == 1'b1 ---> white or king
				if (read_x2 == mx && read_y2 == my) begin
					next_safe_flag = 1'b0;
					next_state = 5'b11010;
				end else begin
					if (next_safe_flag == 1'b0) begin
						next_state = 5'b11010;
					end else begin
						new_read_x = vx;
						new_read_y = vy + 1;
						next_state = 5'b11001;
					end
				end
			end else begin
				next_safe_flag = 1'b1;
				new_read_x = vx;
				new_read_y = vy + 1;
				next_state = 5'b11001;
			end
		end
		5'b11001: begin
			if ((vtype[1] == 1'b1 && throne_empty == 1'b1 && read_x2 == 5 && read_y2 == 5) || (vtype == PIECE_BLACK && read_x2 == 5 && read_y2 == 5) || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 10) || (vtype == PIECE_BLACK && readData2[1] == 1'b1) || (vtype == PIECE_WHITE && readData2 == PIECE_BLACK)) begin //readData2[1] == 1'b1 ---> white or king
				new_read_y = vy - 1;
				next_state = 5'b11011;
				if (read_x2 == mx && read_y2 == my) begin
					next_safe_flag = 1'b0;
				end
			end else begin
				next_state = 5'b11100;
			end
		end
		5'b11010: begin
			//kill piece
			if (safe_flag == 1'b0) begin
				next_write_x = vx;
				next_write_y = vy;
				next_writeData = 2'b00;
				next_write = 1'b1;
				next_safe_flag = 1'b1;
			end
			next_state = 5'b11101;
		end
		5'b11011: begin
			if ((vtype[1] == 1'b1 && throne_empty == 1'b1 && read_x2 == 5 && read_y2 == 5) || (vtype == PIECE_BLACK && read_x2 == 5 && read_y2 == 5) || (read_x2 == 0 && read_y2 == 0) || (read_x2 == 10 && read_y2 == 0) || (read_x2 == 0 && read_y2 == 10) || (read_x2 == 10 && read_y2 == 10) || (vtype == PIECE_BLACK && readData2[1] == 1'b1) || (vtype == PIECE_WHITE && readData2 == PIECE_BLACK)) begin //readData2[1] == 1'b1 ---> white or king
				next_state = 5'b11010;
				if (read_x2 == mx && read_y2 == my) begin
					next_safe_flag = 1'b0;
				end
			end else begin
				next_state = 5'b11100;
			end
		end
		5'b11100: begin
			//don't kill piece
			next_state = 4'b1100;
		end
		5'b11101: begin
			next_write = 1'b0;
			next_state = 4'b1100;
		end
		5'b11110: begin
			next_turn = ~turn;
			new_hx = 5;
			new_hy = 5;
			next_state = 4'b0001;
		end
		5'b11111: begin
			next_state = 6'b100000;
		end
		6'b100000: begin //begin board transmission
			TX_data_next = 8'b11110000;
			TX_start_next = 1'b1;
			next_state = 6'b100110;
		end
		6'b100110: begin
			TX_start_next = 1'b0;
			next_state = 6'b100101;
		end
		6'b100101: begin
			if (TxD_busy) begin
				next_state = 6'b100101;
			end else begin
				next_vx = 0;
				next_vy = 0;
				new_read_x = next_vx;
				new_read_y = next_vy;
				next_state = 6'b100001;
			end
		end
		6'b100001: begin
			next_state = 6'b100111;
			TX_data_next = {6'b001100, readData2};
			TX_start_next = 1'b1;
		end
		6'b100111: begin
			next_state = 6'b100010;
			TX_start_next = 1'b0;
		end
		6'b100010: begin
			if (TxD_busy) begin
				next_state = 6'b100010;
			end else begin
				next_state = 6'b100011;
			end
		end
		6'b100011: begin
			if (vx == 10 && vy == 10) begin
				next_state = 6'b100100; //change this to exit point
				TX_start_next = 1'b1;
				TX_data_next = 10; //newline
			end else begin
				if (next_vx <= 9) begin
					next_vx = vx + 1;
				end else begin
					next_vx = 0;
					next_vy = vy + 1;
				end
				new_read_x = next_vx;
				new_read_y = next_vy;
				next_state = 6'b100001;
			end
		end
		6'b100100: begin
			TX_start_next = 1'b0;
			next_state = 5'b11110;
		end
	endcase
end

endmodule
