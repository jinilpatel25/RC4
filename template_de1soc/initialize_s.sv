`default_nettype none
module initialize_s(data,address,clk,start,finish, selector, reset);

input logic clk, reset;
input logic start;


output logic finish, selector;
output logic [7:0] data, address;

logic [7:0] count = 8'd0;
logic reach_end = 1'b0;

logic [2:0] state, next_state;
logic begin_count;

parameter [2:0] idle = 3'b0_00;
parameter [2:0] start_counter = 3'b1_01;
parameter [2:0] wait_one_cycle = 3'b110;
parameter [2:0] finish_state = 3'b0_10; 

assign begin_count = state[0];
assign finish = state[1];
assign selector = state[2];
assign data = count;
assign address = count;

always_ff @ (posedge clk or negedge reset) begin
    if(~reset) begin
        count <= 8'd0;
        reach_end <= 1'b0;
    end
    else if(begin_count) begin
        count <= count + 8'd1;
    end
end

always_ff @(posedge clk or negedge reset) begin
    if(~reset) begin
        state <= idle;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    case(state)
    idle: if(start) begin
          next_state = start_counter;
          end
          else next_state = idle;
    start_counter: if(count==8'hFF) begin
               next_state = wait_one_cycle;
               end
               else next_state = start_counter;
    wait_one_cycle: next_state = finish_state;
finish_state: next_state = idle;
default: next_state = idle;
endcase
end

endmodule