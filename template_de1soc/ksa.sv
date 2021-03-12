`default_nettype none
module ksa 
  (
    input wire logic CLOCK_50, // Clock pin
    input wire logic  [3:0] KEY, //  -- push button switches
    input wire logic  [9:0] SW, // slider switches
    output wire logic [9:0] LEDR, // red lights
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5
    );


    // clock and reset signals  
	  logic finish_initialization, finish_swapping, wen, swap_wren, selector;
	  logic key_event;
    logic [7:0] address,initial_address,swapped_address;
    logic [7:0] data,initial_data,swapped_data; 
    logic [7:0] q;	
	 
trap_edge generate_synced_pulse(.async_sig(~KEY[2]),
                  .outclk(CLOCK_50), 
                  .out_sync_sig(key_event));

 
	initialize_s initialize_memory(
                                    .data(initial_data),
                                    .address(initial_address),
                                    .clk(CLOCK_50),
                                    .start(key_event),
                                    .finish(finish_initialization), 
                                    .selector(selector), 
                                    .reset(1'b1)
                                  );
   controller swap_memory(.clk(CLOCK_50),
                          .reset(1'b1),
                          .data(swapped_data),
                          .address(swapped_address),
                          .q(q),
                          .start(finish_initialization),
                          .finish(finish_swapping),
                          .switch(SW),
                          .wen(swap_wren),
                          .LEDR(LEDR)
                          );

	 assign address = selector?initial_address:swapped_address;
	 assign data = selector?initial_data:swapped_data;
	 assign wen = selector?1'b1:swap_wren;

   	s_memory RAM(
	             .address(address),
	             .clock(CLOCK_50),
	             .data(data),
	             .wren(wen),
	             .q(q)
               );

endmodule