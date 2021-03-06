`default_nettype none
module compute_output (
    clk,
    reset,
    data_s,
    address_s,
    address_m,
    data_d,
    address_d,
    q_s,
    q_m,
    wren_s,
    wren_d,
    start,
    finish
);

 input logic clk;
 input logic reset;
 //S_RAM Communication
 output logic [7:0] data_s; 
 output logic [7:0] address_s;
 input logic [7:0] q_s;
 output logic wren_s;
 //ROM Communication
 output logic [7:0] address_m; 
 input logic [7:0] q_m;
 //D_RAM Communication
 output logic [7:0] data_d; 
 output logic [7:0] address_d;
 output logic wren_d;
// Start-Finish protocol
 input logic start;
 output logic finish;
//Variable Declaration
logic [7:0] i = 8'd0;
logic [7:0] j = 8'd0;
logic [7:0] k = 8'd0;
logic [7:0] f;
logic [7:0] address_xs; 
logic [7:0] data_xs;
logic [7:0] data_is; 
logic [7:0] data_js; 
logic [7:0] address_xm; 
logic [7:0] address_xd; 
logic [7:0] data_xd; 
logic [7:0] sum;
logic [7:0] data_e;
logic [7:0] data_fs;

//State variable declaration
logic increment_i_var ;
logic update_j_var;
logic increment_k_var;
logic read_value_i;
logic read_value_j;
logic read_data_f;
logic swap_1;
logic swap_2;
logic str_i;
logic str_j;
logic str_data_e;
logic add_for_f_address;
logic str_f;
logic xor_fE_var;
logic readE;
logic send_dram_var;
logic reach_end;

logic [21:0] state, next_state;

assign address_s = address_xs; //S RAM Communication Variables
assign data_s = data_xs;

assign address_m = address_xm; //ROM Communication Variables

assign address_d = address_xd; //D RAM Communication Variables
assign data_d = data_xd;

//State enconding                            876 5432 1098 7654 3210
 parameter [21:0] idle =             22'b000_000_0000_0000_0000_0000;// v
 parameter [21:0] check_cond =       22'b001_000_0000_0000_0000_0000;// |  
 parameter [21:0] increment_i =      22'b000_000_0000_0000_0000_0001;// |  
 parameter [21:0] read_at_i =        22'b000_000_0000_0000_0000_0010;// |    
 parameter [21:0] wait_data_i =      22'b010_000_0000_0000_0000_0000;// |  
 parameter [21:0] capture_data_i =   22'b000_000_0000_0000_0000_0100;// |
 parameter [21:0] update_j =         22'b000_000_0000_0000_0000_1000;// |    
 parameter [21:0] read_at_j =        22'b000_000_0000_0000_0001_0000;// |   
 parameter [21:0] wait_data_j =      22'b011_000_0000_0000_0000_0000;// |
 parameter [21:0] capture_data_j =   22'b000_000_0000_0000_0010_0000;// |
 parameter [21:0] swap_stage_1 =     22'b000_000_0000_0000_0100_0000;// |  
 parameter [21:0] write_stage_1  =   22'b000_010_0000_0000_0000_0000;// |
 parameter [21:0] swap_stage_2  =    22'b000_000_0000_0000_1000_0000;// |    
 parameter [21:0] write_stage_2 =    22'b001_010_0000_0000_0000_0000;// |    
 parameter [21:0] add_data =         22'b000_000_0000_0001_0000_0000;// |    
 parameter [21:0] read_at_add_data = 22'b000_000_0000_0010_0000_0000;// |
 parameter [21:0] wait_added_data =  22'b100_000_0000_0000_0000_0000;// |
 parameter [21:0] capture_f =        22'b000_000_0000_0100_0000_0000;// |
 parameter [21:0] readE_at_k =       22'b000_000_0000_1000_0000_0000;// |
 parameter [21:0] wait_data_E =      22'b101_000_0000_0000_0000_0000;// |
 parameter [21:0] capture_data_E =   22'b000_000_0001_0000_0000_0000;// |
 parameter [21:0] xor_f_Edata =      22'b000_000_0010_0000_0000_0000;// |
 parameter [21:0] send_dram =        22'b000_000_0100_0000_0000_0000;// |
 parameter [21:0] write_dram =       22'b000_100_0000_0000_0000_0000;// |
 parameter [21:0] increment_k =      22'b000_000_1000_0000_0000_0000;// |
 parameter [21:0] finish_stage =     22'b000_001_0000_0000_0000_0000;// 


assign increment_i_var  = state[0] ;
assign read_value_i = state[1] ;
assign str_i = state[2] ;
assign update_j_var = state[3] ;
assign read_value_j = state[4] ;
assign str_j = state[5] ;
assign swap_1 = state[6] ;
assign swap_2 = state[7] ;
assign add_for_f_address = state[8] ;
assign read_data_f = state[9] ;
assign str_f = state[10] ;
assign readE = state[11] ;
assign str_data_e = state[12] ;
assign xor_fE_var = state[13] ;
assign send_dram_var = state[14] ;
assign increment_k_var = state[15] ;
assign finish = state[16] ;
assign wren_s = state[17] ;
assign wren_d = state[18] ;

//========================State machine============================// 

always_ff @(posedge clk or negedge reset) begin
    if(~reset) begin
        state <= idle;
    end
    else begin
        state <= next_state;
    end
end

always @(*) 
begin
    if(~reset) 
    begin
        next_state = idle;
    end
    else 
    begin
        case(state)
            idle: if(start) 
                  begin
                  next_state = check_cond; 
                  end
                  else 
                  begin
                      next_state = idle;
                  end
			check_cond: begin
                        if(reach_end) 
                        begin
                        next_state = finish_stage;
                        end
                        else 
                        begin
                        next_state = increment_i;
                        end
                        end
            increment_i: 
                 begin 
                 next_state = read_at_i;
                 end
            read_at_i: 
                 begin 
                 next_state = wait_data_i;
                 end
            wait_data_i: 
                 begin 
                 next_state = capture_data_i;
                 end
            capture_data_i: 
                 begin 
                 next_state = update_j;
                 end
            update_j: 
                 begin 
                 next_state = read_at_j;
                 end
            read_at_j: 
                 begin 
                 next_state = wait_data_j;
                 end
            wait_data_j: 
                 begin 
                 next_state = capture_data_j;
                 end
            capture_data_j: 
                 begin 
                 next_state = swap_stage_1;
                 end
            swap_stage_1: 
                 begin 
                 next_state = write_stage_1;
                 end
            write_stage_1: 
                 begin 
                 next_state = swap_stage_2;
                 end
            swap_stage_2: 
                 begin 
                 next_state = write_stage_2;
                 end
            write_stage_2: 
                 begin 
                 next_state = add_data;
                 end
            add_data: 
                 begin 
                 next_state = read_at_add_data;
                 end
            read_at_add_data: 
                 begin 
                 next_state = wait_added_data;
                 end
            wait_added_data: 
                 begin 
                 next_state = capture_f;
                 end
            capture_f: 
                 begin 
                 next_state = readE_at_k;
                 end
            readE_at_k: 
                 begin 
                 next_state = wait_data_E;
                 end
            wait_data_E: 
                 begin 
                 next_state = capture_data_E;
                 end
            capture_data_E: 
                 begin 
                 next_state = xor_f_Edata;
                 end
            xor_f_Edata: 
                 begin 
                 next_state = send_dram;
                 end
            send_dram: 
                 begin 
                 next_state = write_dram;
                 end
            write_dram: 
                 begin 
                 next_state = increment_k;
                 end
            increment_k: 
                 begin 
                 next_state = check_cond;
                 end
            finish_stage: 
                 begin 
                 next_state = idle;
                 end
        endcase
    end
end

//====================================================================//

//update i
always_ff @(posedge clk or negedge reset) begin
    if(~reset) begin
        i <= 0;
    end
    else if(increment_i_var) begin
        i <= i + 8'd1;
    end
end

//update j
always_ff @(posedge clk or negedge reset) begin
    if(~reset) begin
        i <= 8'd0;
    end
    else if(update_j_var) begin
        j <= j + data_is;
    end
end

//update K
always_ff @ (posedge clk or negedge reset) begin 
    if(~reset) begin
        k <= 8'd0;
        reach_end <= 1'b0;
    end
    else if(increment_k_var) begin
        if(k < 8'h1F) begin
            reach_end = 1'b0;
            k <= k + 8'd1;
        end
        else begin
            reach_end <= 1'b1;
            k <= 8'd0;
        end
    end
end

always_ff @(posedge clk) begin //read from S Ram and swap 
    
    if(read_value_i) begin
        address_xs <= i;
    end
    else if(read_value_j) begin
        address_xs <= j;
    end
    else if(read_data_f) begin
       address_xs <= sum;
    end
    else if(swap_1) begin
        address_xs <= j;
        data_xs <= data_is;
    end
    else if(swap_2) begin
        address_xs <= i;
        data_xs <= data_js; 
    end

end

// retrieve s[i] value
always_ff @(posedge clk) begin
    if(str_i) begin
        data_is <= q_s;
    end
end

// retrieve s[j] value
always_ff @(posedge clk) begin
    if(str_j) begin
        data_js <= q_s;
    end
end

//retrieve the encrypted data at k
always_ff @(posedge clk) begin
    if(str_data_e) begin
        data_e <= q_m;
    end
end

//add to get address of f
always_ff @(posedge clk) begin
    if(add_for_f_address) begin
        sum <= data_is + data_js;
    end 
end

//retrieve value of f
always_ff @(posedge clk) begin
    if(str_f) begin
        data_fs <= q_s;
    end
end

always_ff @(posedge clk) begin
    if(xor_fE_var) begin
        data_xd <= data_fs ^ data_e;
    end
end

//provide address for E RAM
always_ff @(posedge clk) begin
    if(readE) begin
        address_xm <= k;
    end
end

// provide address to write to dram
always_ff @(posedge clk) begin
    if(send_dram_var) begin
        address_xd <= k;
    end
end
endmodule
