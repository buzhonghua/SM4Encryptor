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
    // data ports
    ,input [group_size_p-1:0] content_i
    ,input [group_size_p-1:0] key_i
    ,input encode_or_decode_i
    // handshake ports
    ,input v_i
    ,output ready_o
    // output encryption value
    ,output [group_size_p-1:0] crypt_o
    // handshake ports
    ,output v_o
    ,input yumi_i
);
    /*
        State Machine of Accelerator:
        eIdle: awaiting input operands.
        eCheckKey: checking whether key is in cache.
        eEvaKey: Evaluate the turn keys, which are sent directly to the cache.
        eCrypt: Encryption/decryption.
        eDone: finished.
    */
    typedef enum logic [3:0] {eIdle, eCheckKey, eEvaKey, eCrypt, eDone} state_e;
    state_e state_r;

    wire cache_is_miss; 
    wire iteration_is_done; // signal indicating whether iteration (eEvaKey, eCrypt) is the complete.

    // State Machine
    always_ff @(posedge clk_i) begin
        if(reset_i) state_r <= eIdle;
        else unique case(state_r) 
            eIdle: if(v_i) state_r <= eCheckKey;
            eCheckKey: if(cache_is_miss) state_r <= eEvaKey; else state_r <= eCrypt;
            eEvaKey: if(iteration_is_done) state_r <= eCrypt; else state_r <= eEvaKey;
            eCrypt: if(iteration_is_done) state_r <= eDone; else state_r <= eCrypt;
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
        if(reset_i) state_cnt_r <= '0
        else unique case(state_r)
            eCheckKey: state_cnt_r <= '0;
            eEvaKey: state_cnt_r <= state_cnt_n;
            eCrypt: state_cnt_r <= state_cnt_n;
            default: state_cnt_r <= '0; // This should be replaced with a random number for preventing PDA.
        endcase
    end

    

endmodule

