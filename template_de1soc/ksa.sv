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
	  logic start2A, start3A, start4, wren, wren_3s, wren_2s,wren_d, selector1,selector2,selector3;
	  logic key_event;
    logic [7:0] address,address_1s,address_2s,address_3s,address_m,address_d;
    logic [7:0] data,data_1s,data_2s,data_3s,data_d; 
    logic [7:0] q,q_m,q_d;	
    logic [2:0] select;
	 
 trap_edge generate_synced_pulse(.async_sig(~KEY[2]),
                  .outclk(CLOCK_50), 
                  .out_sync_sig(key_event));

 
	initialize_s initialize_memory(
                                    .data(data_1s),
                                    .address(address_1s),
                                    .clk(CLOCK_50),
                                    .start(key_event),
                                    .finish(start2A), 
                                    .selector(selector1), 
                                    .reset(1'b1)
                                  );

   controller swap_memory(.clk(CLOCK_50),
                          .reset(1'b1),
                          .data(data_2s),
                          .address(address_2s),
                          .q(q),
                          .start(start2A),
                          .finish(start3A),
                          .switch(SW),
                          .wen(wren_2s),
                          .selector2(selector2)
                          );

    compute_output task_2b(.clk(CLOCK_50),
                           .reset(1'b1),
                           .data_s(data_3s),
                           .address_s(address_3s),
                           .address_m(address_m),
                           .data_d(data_d),
                           .address_d(address_d),
                           .q_s(q),
                           .q_m(q_m),
                           .wren_s(wren_3s),
                           .wren_d(wren_d),
                           .start(start3A),
                           .finish(start4),
                           .selector3(selector3)
                          );

   	s_memory RAM(
	             .address(address),
	             .clock(CLOCK_50),
	             .data(data),
	             .wren(wren),
	             .q(q)
               );
    
    decrypted_memory DRAM(
	             .address(address_d),
	             .clock(CLOCK_50),
	             .data(data_d),
	             .wren(wren_d),
	             .q(q_d)
               );

    encrypted_input EROM(.clock(CLOCK_50),
                         .address(address_m),
                         .q(q_m)
                        );

    assign select = {selector1,selector2,selector3};

    always @(*) begin
      case(select)
      3'b100: begin
           address = address_1s;
           data = data_1s;
           wren = 1'b1;
      end
      3'b010: begin
           address = address_2s;
           data = data_2s;
           wren = wren_2s;
      end
      3'b001: begin
           address = address_3s;
           data = data_3s;
           wren = wren_3s;
      end
      default: begin
            address = 8'bx;
            data = 8'bx;
            wren = 1'bx;
      end
		endcase
    end
    
endmodule