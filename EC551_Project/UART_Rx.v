//////////////////////////////////////////////////////////////////////////////////
// Company: 	Boston University
// Engineer: 	Zafar M. Takhirov
// 
// Create Date:    02:29:08 10/29/2012 
// Design Name: 	 Asynchronous communication
// Module Name:    UART_Rx
// Project Name: 	 ANN
// Target Devices: xc6slx16-3csg324
// Tool versions:  ISE 12.2
//
// Dependencies: 	 none
//
// Revision: 
// 	Revision 0.01 - File Created
//
// Additional Comments: 
//		Comments talk about Matlab communcation, but this is a generic driver
//		start and stop bit are saved, for future purposes
//
//////////////////////////////////////////////////////////////////////////////////
`define IDLE	0
`define START	1
`define DATA	2
`define STOP	3
`define HOLDIT 4

module UART_Rx(
	output reg [7:0] o_data,	// received data (parallel)
	input i_TX,		// Comes FROM Matlab	
	input clk,		// 100MHz clock signal
	input reset,		// global reset
	output done
    );
	
	// Baud rate calculation
	parameter FREQUENCY = 100_000_000;			// onboard frequency (100 MHz)
	parameter BAUDRATE = 921_600;					// communication bandwidth
	parameter T_COUNT = FREQUENCY/BAUDRATE;	// counting till this
	
	reg [2:0] state, next_state;	// states
	reg [9:0] r_data = 0;	// shift register
	reg [25:0] count = 0;	// time counter, make sure T_COUNT fits in here
	reg [3:0] i = 0;		// bit counter
	reg donereg = 1'b0;
	reg [25:0] cc = 0;
	
	// FSM
	always @ (posedge clk or posedge reset) 
		if (reset) state = `IDLE;
		else state = next_state;
	
	always @ (posedge clk) begin
		case (state)
			// IDLE state waits for the start bit to appear
			`IDLE: begin						// Wait for data to arrive
					donereg = 1'b0;
					count = 0;					// not counting
					i = 0;
					if (~i_TX) next_state = `START;	// if start bit received
					else next_state = `IDLE;			// else stay here
				end
			`START: begin	// start bit
					if (count >= T_COUNT/2) begin 	// half-time for mid-bit sampling
						next_state = `DATA;				// start receiving the data
						count = 0;							// reset the count
						r_data[i] = i_TX;					// save the start bit
						i = i + 1'b1;						// increment the bit counter
					end else begin
						next_state = `START;				// otherwise stay here
						count = count + 1'b1;			// and keep on incrementing the count
					end
				end
			`DATA: begin	// count till ten, record the bit, increment it, repeat 8 times
					if (i <= 9) begin	// start + data
						next_state = `DATA;
						if (count >= T_COUNT) begin
							count = 0;
							r_data[i] = i_TX;
							i = i + 1'b1;
						end else begin
							count = count + 1'b1;
						end
					end else begin 
						next_state = `STOP;
						count = 0;
					end
				end
				`HOLDIT: begin
					if (cc == 1) begin
						donereg = 1'b1;
					end else begin
						donereg = 1'b0;
					end
					cc = cc + 1;
					if (cc > 25000) begin
						cc = 0;
						next_state = `IDLE;
					end
				end
			`STOP: begin	// once done, check for the stop bit (can be replaced by parity)
					if (count >= 1) begin
						next_state = `HOLDIT;		// and go to the initial state
						count = 0;					// reset the counting
						r_data[i] = i_TX;			// get the stop bit
						o_data = r_data[8:1];	// output parallel data
					end else begin
						donereg = 1'b0;
						next_state = `STOP;		// wait for the stop bit to arrive
						count = count + 1'b1;
					end
				end
				
		endcase	
	end
	assign done = donereg;
endmodule
