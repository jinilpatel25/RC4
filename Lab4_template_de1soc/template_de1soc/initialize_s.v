`default_nettype none
module initialize_s(data,address,clk,wen,q);

input wire clk;

output reg wen;
output reg [7:0] data, address,q;

reg [7:0] count = 8'd0;

assign wen = 1'b1;

s_memory lets_initialize(address,clk,data,wen,q);

always_ff @ (posedge clk) begin
    data <= count;
    address <= count;
    if(count < 255) begin
    count <= count + 8'd1;     
    end
end
endmodule