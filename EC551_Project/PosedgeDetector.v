`timescale 1ns / 1ps

module PosedgeDetector(input clk, input signal, output edgeout);
	reg signal_d;
 
	always @ (posedge clk) begin
		signal_d <= signal;
	end
	
	assign edgeout = signal & (~signal_d);

endmodule
