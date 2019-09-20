// -------------------------------------------------------
// -- key_cache.sv
// -------------------------------------------------------
// This file implements a cache system for storing turn keys.
// -------------------------------------------------------

module key_cache 
    import sm4_encryptor::*;
#(
    parameter integer width_p = turn_key_num_p*key_size_p
    ,parameter integer capacity_p = 4
)(
    input clk_i
    ,input reset_i

    ,input [group_size_p-1:0] key_i
    ,input [$clog2(turn_key_num_p)-1:0] which_turn_key_i
    ,input [1:0] op_i // 0 for read, 1 for write, 2 for check and allocate.
    ,input v_i

    ,output [key_size_p-1:0] tkey_o
    ,output hit_o
    ,output v_o
);


endmodule
