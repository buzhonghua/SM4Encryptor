// -------------------------------------------------------
// -- key_cache.sv
// -------------------------------------------------------
// This file implements a cache system for storing turn keys.
// -------------------------------------------------------
import sm4_encryptor_pkg::*;

module key_cache #(
    parameter bit debug_p = 0
)(
    input clk_i
    ,input reset_i

    // setting address ports
    ,input [group_size_p-1:0] key_i
    ,input v_key_i
    ,output is_missed_o // Zero Delay Path!
    // reading ports
    ,input [$clog2(turn_key_num_p)-1:0] idx_r_i
    ,input v_r_i

    // Write ports for cache. Write destination is always the last reading one.
    ,input [word_width_p-1:0] w_i
    ,input [$clog2(turn_key_num_p)-1:0] idx_w_i
    ,input v_w_i

    ,output [word_width_p-1:0] tkey_o
    // invalid all cache line.
    ,input invalid_i
);

reg [3:0] cache_valid_r; // zero after reset, 1 after access.

reg [3:0][group_size_p-1:0] cam_r;
wire [3:0] hit;
wire [1:0] which;

// Find which one is the hit
for(genvar i = 0; i < 4; ++i) begin
    assign hit[i] = (cam_r[i] == key_i) && cache_valid_r[i];
end

priority_encoder enc(
    .i(hit)
    ,.o(which)
);


wire miss = (hit == '0);
wire [1:0] to_replace;
wire [1:0] selected_n = miss ? to_replace : which;
reg [1:0] selected_r;

lru_recorder lru(
    .clk_i(clk_i)
    ,.reset_i(reset_i | invalid_i)

    ,.access1_i(selected_n)
    ,.v1_i(v_key_i)

    ,.access2_i(selected_r)
    ,.v2_i(v_w_i | v_r_i)

    ,.replace_which_o(to_replace)
);

always_ff @(posedge clk_i) begin
    if(reset_i | invalid_i) selected_r <= '0;
    else if(v_key_i) selected_r <= selected_n;
end

// Cache valid register

always_ff @(posedge clk_i) begin
    if(reset_i | invalid_i) cache_valid_r <= '0;
    else if(v_key_i) begin
        cache_valid_r[selected_n] <= 1'b1;
    end
end

// CAM update
always_ff @(posedge clk_i) begin
    if(reset_i) cam_r <= '0;
    else if(v_key_i && miss) 
        cam_r[to_replace] <= key_i;
end

// Cache groups.
reg [3:0][turn_key_num_p-1:0][word_width_p-1:0] cache_r;
// Cache write logic.
always_ff @(posedge clk_i) begin
    if(reset_i) begin
        cache_r <= '0;
    end
    else if(v_w_i) begin
        cache_r[selected_r][idx_w_i] <= w_i;
    end
end
// For reading.
// Forwarding is used.
assign tkey_o = cache_r[selected_r][idx_r_i];
assign is_missed_o = miss;

if(debug_p) 
    always_ff @(posedge clk_i) begin
        for(integer i = 0; i < 4; ++i) begin
            $display("CAM[%d] = %x", i, cam_r[i]);
        end
    end

endmodule
