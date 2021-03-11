`default_nettype none
module controller(clk,reset,data,address,q,start,finish,switch,wen);

input logic clk,reset,start;
input logic [7:0] q;
input logic [9:0] switch;

output logic finish,wen;
output logic [7:0] data,address;
assign address = address_x;
assign data = data_x;

logic [10:0] state, next_state; //state variables

logic [7:0] secret_key[2:0];
assign secret_key[0] = 8'b0;
assign secret_key[1] = {6'b0,switch[9:8]};
assign secret_key[2] = switch[7:0];

logic [7:0] i = 8'b0; //address variables
logic [7:0] j = 8'b0;

logic increment_i; //flags to update address variables
logic change_j;

logic reach_end = 1'b0;

logic [7:0] data_i, data_j; //data variables

logic swap_1; //swap flags
logic swap_2;

logic read_value_i, read_value_j; //read flags

logic [7:0] address_x,data_x; //address and data variables

logic str_i, str_j; //flags to start storing
                            //98_7654_3210
parameter [10:0] idle = 11'b0_00_0000_0000;
parameter [10:0] check_cond = 11'b1_00_0000_0000;
parameter [10:0] read_at_location_i = 11'b0_10_0000_0000;
parameter [10:0] store_data_i = 11'b0_01_0000_0000;
parameter [10:0] update_j = 11'b0_00_1000_0000;
parameter [10:0] read_at_location_j = 11'b0_00_0100_0000;
parameter [10:0] store_data_j = 11'b0_00_0010_0000;
parameter [10:0] swap_stage_1 = 11'b0_00_0001_0001;
parameter [10:0] swap_stage_2 = 11'b0_00_0000_1001;
parameter [10:0] update_i = 11'b0_00_0000_0100;
parameter [10:0] finish_stage = 11'b0_00_0000_0010;

assign read_value_i = state[9];
assign str_i = state[8];
assign change_j = state[7];
assign read_value_j = state[6];
assign str_j = state[5];
assign swap_1 = state[4];
assign swap_2 = state[3];
assign increment_i = state[2];
assign finish = state[1];
assign wen = state[0];

always_ff @ (posedge clk or negedge reset) begin //update i
    if(~reset) begin
        i <= 8'd0;
        reach_end <= 1'b0;
    end
    else if(increment_i) begin
        if(i < 8'hFF) begin
            reach_end = 1'b0;
            i <= i + 8'd1;
        end
        else begin
            reach_end <= 1'b1;
            i <= i + 8'd1;
        end
    end
end

always_ff @(posedge clk or negedge reset) begin //update j
    if(~reset) begin
        j <= 8'h0;
    end
    else if(change_j) begin
        j <= j + data_i + secret_key[i%3];
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
    if(~reset) begin
        next_state = idle;
    end
    else begin
        next_state = state;
        case(state)
            idle: if(start) begin
                  next_state = read_at_location_i; 
                  end
            /*check_cond: if(i != 8'hFF) begin
                        next_state = read_at_location_i;
                        end
                        else begin
                            next_state = finish;
                        end */
            read_at_location_i: next_state = store_data_i;
            store_data_i: next_state = update_j;
            update_j: next_state = read_at_location_j;
            read_at_location_j: next_state = store_data_j;
            store_data_j: next_state = swap_stage_1;
            swap_stage_1: next_state = swap_stage_2;
            swap_stage_2: next_state = update_i;
            update_i: if(reach_end) begin
				          next_state = finish_stage;
							 end
							 else begin
							 next_state = read_at_location_i;
							 end
            finish_stage: next_state = idle;
            default: next_state = idle;
        endcase
    end
end

always_ff @(posedge clk) begin
    if(read_value_i) begin
        address_x <= i;
    end
    else if(read_value_j) begin
        address_x <= j;
    end
    else if(swap_1) begin
        address_x <= j;
        data_x <= data_i;
    end
    else if(swap_2) begin
        address_x <= i;
        data_x <= data_j; 
    end
end

always_ff @(posedge str_i) begin
    data_i <= q;
end

always_ff @(posedge str_j) begin
    data_j <= q;
end
endmodule