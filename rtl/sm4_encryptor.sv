// -------------------------------------------------------
// -- sm4_encryptor.sv
// -------------------------------------------------------
// top module of SM4 encryptor.
// -------------------------------------------------------

module sm4_encryptor
    import sm4_encryptor::*;
(
    input clk_i
    ,input reset_i
    ,input [group_size_p-1:0] content_i
    ,input [group_size_p-1:0] key_i
    ,input encode_or_decode_i

    ,input v_i
    ,output ready_o

    
)
