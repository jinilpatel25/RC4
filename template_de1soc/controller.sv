`default_nettype none
module controller(clk,reset,data,address,q,start,finish,switch,wen);

// variable declaration
//Input
input logic clk,reset,start;
input logic [7:0] q;
input logic [9:0] switch;
//Output
output logic finish,wen;
output logic [7:0] data,address;
//State variables
logic [11:0] state;
logic [11:0] next_state;  
//address variables
logic [7:0] i = 8'd0; 
logic [7:0] j = 8'd0;
//flags to update address variables
logic increment_i; 
logic change_j;
logic reach_end = 1'b0;
//swap flags
logic swap_1; 
logic swap_2;
//data variables
logic [7:0] data_i; 
logic [7:0] data_j; 
//read flags
logic read_value_i, read_value_j; 
//address and data variables
logic [7:0] address_x; 
logic [7:0] data_x;
//flags to start storing
logic str_i, str_j; 
// Secrete key encoding
logic [7:0] secret_key[2:0];
assign secret_key[0] = 8'b0;
assign secret_key[1] = {6'b0,switch[9:8]};
assign secret_key[2] = switch[7:0];
//assign output values
assign address = address_x;
assign data = data_x;

//State Encoding 
                                           //98_7654_3210
parameter [11:0] idle               = 12'b00_00_0000_0000;//    0            
parameter [11:0] read_at_location_i = 12'b00_10_0000_0000;//    200
parameter [11:0] store_data_i       = 12'b00_01_0000_0000;//    100
parameter [11:0] update_j           = 12'b00_00_1000_0000;//    80
parameter [11:0] read_at_location_j = 12'b00_00_0100_0000;//    40
parameter [11:0] store_data_j       = 12'b00_00_0010_0000;//    20
parameter [11:0] swap_stage_1       = 12'b00_00_0001_0000;//    10
parameter [11:0] write_stage_1      = 12'b00_00_0000_0001;//    1
parameter [11:0] swap_stage_2       = 12'b00_00_0000_1000;//    8
parameter [11:0] write_stage_2      = 12'b01_00_0000_0001;//    401
parameter [11:0] update_i           = 12'b00_00_0000_0100;//    4
parameter [11:0] finish_stage       = 12'b00_00_0000_0010;//    2
parameter [11:0] wait_data_i        = 12'b01_00_0000_0000;//    400
parameter [11:0] wait_data_j        = 12'b10_00_0000_0000;//    800
parameter [11:0] check_cond         = 12'b11_00_0000_0000;//    1200

assign read_value_i  = state[9];
assign str_i         = state[8];
assign change_j      = state[7];
assign read_value_j  = state[6];
assign str_j         = state[5];
assign swap_1        = state[4];
assign swap_2        = state[3];
assign increment_i   = state[2];
assign finish        = state[1];
assign wen           = state[0];




//========================State machine============================//

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
        case(state)
            idle: if(start) begin
                  next_state = check_cond; 
                  end
                  else begin
                      next_state = idle;
                  end
			check_cond: begin
                        if(reach_end) begin
                        next_state = finish_stage;
                        end
                        else begin
                        next_state = read_at_location_i;
                        end
				end            
            read_at_location_i: begin
                next_state = wait_data_i;
            end

            wait_data_i: begin
                next_state = store_data_i;
            end

            store_data_i:begin
                next_state = update_j;
            end 

            update_j: begin
                next_state = read_at_location_j;
            end 
            read_at_location_j:begin
                next_state = wait_data_j;
            end
			   wait_data_j: begin
					 next_state = store_data_j;
			   end	
            store_data_j:begin
                next_state = swap_stage_1;
            end 
            swap_stage_1:begin
                next_state = write_stage_1;
            end 
            write_stage_1:begin
                next_state = swap_stage_2;
            end 
            swap_stage_2:begin
                next_state = write_stage_2;
            end 
            write_stage_2:begin
                next_state = update_i;
            end 

            update_i: begin
				    next_state = check_cond;
				end
            finish_stage:begin
                next_state = idle;
            end 
            default:begin
                next_state = idle;
            end 
        endcase
    end
end

//====================================================================//

//update for i = 0 to 255
always_ff @ (posedge clk or negedge reset) begin 
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
            i <= 8'd0;
        end
    end
end


always_ff @(posedge clk) begin //read and swap
    
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

// retreave s[i] value
always_ff @(posedge clk) begin
    if(str_i) begin
        data_i <= q;
    end
end

// retreave s[j] value
always_ff @(posedge clk) begin
    if(str_j) begin
        data_j <= q;
    end
    
end

//update j = j + s[i] + secret_key[i % 3];
always_ff @(posedge clk or negedge reset) begin 
    if(~reset) begin
        j <= 8'd0;
    end
    else if(change_j) begin
        j <= j + data_i + secret_key[i % 8'd3];
    end
	 else if(finish) begin
	     j <= 8'd0;
	 end
end

endmodule