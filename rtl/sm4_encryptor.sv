// -------------------------------------------------------
// -- sm4_encryptor.sv
// -------------------------------------------------------
// top module of SM4 encryptor.
// -------------------------------------------------------

module sm4_encryptor
    import sm4_encryptor_pkg::*;
(
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
);
    /*
        State Machine of Accelerator:
        eIdle: awaiting input operands.
        eCheckKey: checking whether key is in cache.
        eEvaKey: Evaluate the turn keys, which are sent directly to the cache.
        eLoadCrypt: Load content to register.
        eCrypt: Encryption/decryption.
        eReverse: Reverse the order of encryption
        eDone: finished.
    */
    typedef enum logic [3:0] {eIdle, eCheckKey, eEvaKey, eLoadCrypt, eCrypt, eReverse, eDone} state_e;
    state_e state_r;

    wire cache_is_miss; 
    wire iteration_is_done; // signal indicating whether iteration (eEvaKey, eCrypt) is the complete.

    // State Machine
    always_ff @(posedge clk_i) begin
        if(reset_i) state_r <= eIdle;
        else unique case(state_r) 
            eIdle: if(v_i) state_r <= eCheckKey;
            eCheckKey: if(cache_is_miss) state_r <= eEvaKey; else state_r <= eLoadCrypt;
            eEvaKey: if(iteration_is_done) state_r <= eLoadCrypt; else state_r <= eEvaKey;
            eLoadCrypt: state_r <= eCrypt;
            eCrypt: if(iteration_is_done) state_r <= eReverse; else state_r <= eCrypt;
            eReverse: state_r <= eDone;
            eDone: if(yumi_i) state_r <= eIdle; else state_r <= eDone;
            default: state_r <= state_r;
        endcase
    end

    localparam state_cnt_lp = 32;
    reg [$clog2(state_cnt_lp)-1:0] state_cnt_r; // Iteration counter.
    wire [$clog2(state_cnt_lp)-1:0] state_cnt_n = state_cnt_r + 1;

    assign iteration_is_done = state_cnt_r == '1;

    // Control signal for state_cnt_r
    always_ff @(posedge clk_i) begin
        if(reset_i) state_cnt_r <= '0;
        else unique case(state_r)
            eEvaKey: state_cnt_r <= state_cnt_n;
            eCrypt: state_cnt_r <= state_cnt_n;
            default: state_cnt_r <= '0; // This should be replaced with a random number for preventing PDA.
        endcase
    end

    reg [group_size_p-1:0] sfr_r; // register containing current operand to perform turn keys
    wire [group_size_p-1:0] xor_res = sfr_r ^ key_xor_mask_p;
    wire [word_width_p-1:0] turn_transform_res;
    always_ff @(posedge clk_i) begin
        if(reset_i) begin
            sfr_r <= '0; 
        end
        else unique case(state_r)
            eIdle: if(v_i) sfr_r <= key_i;
            eCheckKey: sfr_r <= xor_res;
            eEvaKey: sfr_r <= {turn_transform_res ,sfr_r[group_size_p-1:word_width_p]};
            eLoadCrypt: sfr_r <= content_i;
            eCrypt: sfr_r <= {turn_transform_res ,sfr_r[group_size_p-1:word_width_p]};
            eReverse: sfr_r <= { sfr_r[word_width_p-1:0], sfr_r[2*word_width_p-1:word_width_p], sfr_r[3*word_width_p-1:2*word_width_p], sfr_r[group_size_p-1:3*word_width_p]};
            default: begin

            end
        endcase
    end

    logic [word_width_p-1:0] turn_rkeys;

    turn_transform turn (
        .i(sfr_r)
        ,.is_key_i(state_r == eEvaKey)
        ,.rkey_i(turn_rkeys)
        ,.o(turn_transform_res)
        ,.testing_clk_i()
    );

    logic [word_width_p-1:0] cache_output;

    always_comb begin
        if(state_r == eEvaKey) begin
            turn_rkeys = key_aux_p[state_cnt_r];
        end
        else begin
            turn_rkeys = cache_output;
        end
    end

    reg decode_r;
    // Update decode_r.`
    always_ff @(posedge clk_i) begin
        if(reset_i) decode_r <= '0;
        else if(state_r == eIdle && v_i) decode_r <= encode_or_decode_i;
    end

    // Cache used for storing keys.
    key_cache cache (
        .clk_i(clk_i)
        ,.reset_i(reset_i)

        ,.key_i(sfr_r)
        ,.v_key_i(state_r == eCheckKey)
        ,.is_missed_o(cache_is_miss)

        ,.idx_r_i(state_cnt_r ^ {($clog2(state_cnt_lp)){decode_r}})
        ,.v_r_i(state_r == eCrypt)

        ,.w_i(turn_transform_res)
        ,.idx_w_i(state_cnt_r)
        ,.v_w_i(state_r == eEvaKey)

        ,.tkey_o(cache_output)

        ,.invalid_i(invalid_cache_i)
    );

    assign ready_o = state_r == eIdle;
    assign crypt_o = sfr_r;
    assign v_o = state_r == eDone;

endmodule

