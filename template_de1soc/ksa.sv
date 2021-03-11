module ksa 
  (
    input logic CLOCK_50, // Clock pin
    input [3:0] KEY, //  -- push button switches
    input [9:0] SW, // slider switches
    output [9:0] LEDR, // red lights
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
    );

    // clock and reset signals  
	logic clk, reset_n, wren, clock;
    logic [7:0] address;
    logic [7:0] data; 
    logic [7:0] q;

    assign reset_n = KEY[3];
    initialize_s call_initialize(.data(data),
                                 .address(address),
                                 .clk(CLOCK_50),
                                 .start(~KEY[0]),
                                 .finish(), 
                                 .selector(wren), 
                                 .reset(KEY[1]));
    s_memory write_read_memory(.address(address),
                               .clock(CLOCK_50),
                               .data(data),
                               .wren(wren),
                               .q());

endmodule