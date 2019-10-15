
// -------------------------------------------------------
// -- sm4_encryptor_wrapper.sv
// -------------------------------------------------------
// This is a wrapper for top module of sm4_encryptor, with purpose of UVM facilities.
// -------------------------------------------------------

import sm4_encryptor_pkg::*;

module sm4_encryptor_wrapper(
    input clk_i
    ,input reset_i
    // data ports
    ,input [group_size_p-1:0] content_i
    ,input [group_size_p-1:0] key_i
    ,input encode_or_decode_i // decode is 1.
    // handshake ports
    ,input v_i
    ,output ready_o
    // output encryption value
    ,output [group_size_p-1:0] crypt_o
    // handshake ports
    ,output v_o
    ,input yumi_i
    // invalid cache lines.
    ,input invalid_cache_i
    // SM4 FSM
    ,output state_e state_o
    ,output [4:0] state_cnt_o
    //SM4 GPR
    ,output [group_size_p-1:0] sfr_o
    // Cache
    ,output [1:0] replace_which_o
    ,output [1:0] selected_o
    ,output cache_is_missed_o
    // Cache data`
    ,output [3:0][group_size_p-1:0] cam_o
    ,output [3:0] cache_data_o
    ,output [3:0] cache_valid_o
);

sm4_encryptor core( .* );

assign state_o = core.state_cnt_r;
assign state_cnt_o = core.state_cnt_r;
assign sfr_o = core.sfr_r;
assign replace_which_o = core.cache.to_replace;
assign selected_o = core.cache.selected_n;
assign cache_is_missed_o = core.cache_is_miss;
assign cam_o = core.cache.cam_r;
assign cache_data_o = core.cache.cache_r;
assign cache_valid_o = core.cache.cache_valid_r;

endmodule
