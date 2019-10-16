


interface sm4_encryptor_if
    import sm4_encryptor_pkg::*;
(

);
    
logic clk_i;
logic reset_i;

logic [group_size_p-1:0] content_i;
logic [group_size_p-1:0] key_i;
logic encode_or_decode_i; // decode is 1.
// handshake ports
logic v_i;
logic ready_o;
// output encryption value
logic [group_size_p-1:0] crypt_o;
// handshake ports
logic v_o;
logic yumi_i;
// invalid cache lines.
logic invalid_cache_i;
// SM4 FSM
state_e state_o;
logic [4:0] state_cnt_o;
//SM4 GPR
logic [group_size_p-1:0] sfr_o;
// Cache
logic [1:0] replace_which_o;
logic [1:0] selected_o;
logic cache_is_missed_o;

endinterface
