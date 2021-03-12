module arDFF #(parameter N = 2)
                     (input logic clk,
                      input logic reset,
                      input logic [N-1:0]d,
                      output logic [N-1:0] q);
// asyschronous reset
always_ff @(posedge clk, posedge reset)
    if(reset) q <= 0;
    else      q <= d;

endmodule
