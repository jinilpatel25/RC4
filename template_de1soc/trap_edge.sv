module trap_edge (input logic async_sig, 
                  input logic outclk, 
                  output logic out_sync_sig);

logic out_1;
logic out_2;
logic out_3;
logic out_4;

arDFF #(.N(1)) FFf(.clk(async_sig),.reset(out_4), .d(1'b1), .q(out_1));
arDFF #(.N(1)) FFs(.clk(outclk),.reset(1'b0), .d(out_1), .q(out_2));
arDFF #(.N(1)) FFt(.clk(outclk),.reset(1'b0), .d(out_2), .q(out_3));
arDFF #(.N(1)) FFfo(.clk(outclk),.reset(1'b0), .d(out_3), .q(out_4));

assign out_sync_sig = out_3 ;

endmodule