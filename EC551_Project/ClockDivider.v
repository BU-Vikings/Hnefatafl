`timescale 1ns / 1ps

module GameClockDivider #(parameter hz = 100)(
    clk_in,
    clk_out
    );
	 parameter max_count = 100000000 / hz;
	 
    input clk_in;
    output clk_out;
	 reg c_out = 1'b0;
	 reg [28:0] count = 29'b0;
	 always @ (posedge clk_in) begin
			count <= count + 1'b1;
			if (count >= max_count) begin
				c_out <= c_out + 1'b1;
				count <= 29'b0;
			end
	end
	assign clk_out = c_out;
endmodule
