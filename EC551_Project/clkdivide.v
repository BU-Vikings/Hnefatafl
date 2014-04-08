
module dcm_all_v2 #(parameter DCM_DIVIDE = 5,
 DCM_MULTIPLY = 2)
 (
 CLK,
 CLKSYS,
 CLK_out
);



input CLK;
// input RST;
 output CLKSYS;
// output CLK25;
 output CLK_out;
//

 // Output registers
 wire CLKSYS;
 wire CLK25;
 wire CLK_out;
 // architecture of dcm_all entity
 wire GND = 1'b0;
 wire CLKSYSint;
 wire CLKSYSbuf;
 assign CLKSYS = CLKSYSbuf;
//

 BUFG BUFG_clksys(
 .O(CLKSYSbuf),
 .I(CLKSYSint)
 );
 // Instantiation of the DCM device primitive.
 // Feedback is not used.
 // Clock multiplier is 2
 // Clock divider is 5
 // 100MHz * 2/5 = 40MHz
 // The following generics are only necessary if you wish to change the default
 DCM #(
 .CLK_FEEDBACK("1X"),
 .CLKDV_DIVIDE(5.0), // Divide by:
 .CLKFX_DIVIDE(5), // Can be any interger from 2 to 32
 .CLKFX_MULTIPLY(2), // Can be any integer from 2 to 32
 .CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN
 .CLKIN_PERIOD(10000.0), // Specify period of input clock (ps)
 .CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE,
 .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
 .DFS_FREQUENCY_MODE("LOW"),
 .DLL_FREQUENCY_MODE("LOW"),
 .DUTY_CYCLE_CORRECTION("TRUE"), 
 .FACTORY_JF(16'hC080), // FACTORY JF Values
 .PHASE_SHIFT(0),
.STARTUP_WAIT("FALSE")
 )
 DCM_inst(
 .CLK0(CLKSYSint), // 0 degree DCM CLK ouptput
 .CLK180(), // 180 degree DCM CLK output
 .CLK270(), // 270 degree DCM CLK output
 .CLK2X(), // 2X DCM CLK output
 .CLK2X180(), // 2X, 180 degree DCM CLK out
 .CLK90(), // 90 degree DCM CLK output
 .CLKDV(), //(CLK25), // Divided DCM CLK out (CLKDV_DIVIDE)
 .CLKFX(CLK_out), // DCM CLK synthesis out (M/D)
 .CLKFX180(), // 180 degree CLK synthesis out
 .LOCKED(), // DCM LOCK status output
 .PSDONE(), // Dynamic phase adjust done output
 .STATUS(), // 8-bit DCM status bits output
 .CLKFB(CLKSYSbuf), // DCM clock feedback
 .CLKIN(CLK), // Clock input (from IBUFG, BUFG or DCM)
 .PSCLK(GND), // Dynamic phase adjust clock input
 .PSEN(GND), // Dynamic phase adjust enable input
 .PSINCDEC(GND), // Dynamic phase adjust
 .DSSEN(1'b0),
.RST (1'b0) //(RST) // DCM asynchronous reset input
 );
endmodule
/////////////////////////////////////////////////////