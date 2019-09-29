
// -------------------------------------------------------
// -- sm4_encryptor_wrapper.sv
// -------------------------------------------------------
// This is a wrapper for top module of sm4_encryptor, with purpose of UVM facilities.
// -------------------------------------------------------

import sm4_encryptor_pkg::*;

interface sm4_encryptor_if(
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

endinterface


module sm4_encryptor_wrapper(
    sm4_encryptor_if inf
);

sm4_encryptor core(
    ,.clk_i(inf.clk_i)
    ,.reset_i(inf.reset_i)
    ,.content_i(inf.content_i)
    ,.key_i(inf.key_i)
    ,.encode_or_decode_i(inf.encode_or_decode_i)
    ,.v_i(inf.v_i)
    ,.ready_o(inf.ready_o)
    ,.crypt_o(inf.crypt_o)
    ,.v_o(inf.v_o)
    ,.yumi_i(inf.yumi_i)
    ,.invalid_cache_i(inf.invalid_cache_i)
);

assign inf.state_o = core.state_cnt_r;
assign inf.state_cnt_o = core.state_cnt_r;
assign inf.sfr_o = core.sfr_r;
assign inf.replace_which_o = core.cache.to_replace;
assign inf.selected_o = core.cache.selected_n;
assign inf.cache_is_missed_o = core.cache_is_miss;
assign inf.cam_o = core.cache.cam_r;
assign inf.cache_data_o = core.cache.cache_r;
assign inf.cache_valid_o = core.cache.cache_valid_r;

endmodule
