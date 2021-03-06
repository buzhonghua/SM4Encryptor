// -------------------------------------------------------
// -- sm4_encryptor.sv
// -------------------------------------------------------
// top module of SM4 encryptor.
// -------------------------------------------------------

module sm4_encryptor
    import sm4_encryptor_pkg::*;
#(
    parameter bit cache_is_enabled_p = 1'b1
)(
    input clk_i
    ,input reset_i
    // data ports
    ,input [group_size_p-1:0] content_i
    ,input [group_size_p-1:0] key_i
    ,input [word_width_p-1:0] random_i
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
    ,input protection_v_i
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
    state_e state_r;

    wire cache_is_miss; 
    wire iteration_is_done; // signal indicating whether iteration (eEvaKey, eCrypt) is the complete.
    wire need_check;
    logic check_is_match;

    // State Machine
    always_ff @(posedge clk_i) begin
        if(reset_i) state_r <= eIdle;
        else unique case(state_r) 
            eIdle: if(v_i) state_r <= eCheckKey;
            eCheckKey: if(cache_is_miss) state_r <= eEvaKey; else state_r <= eLoadCrypt;
            eEvaKey: if(iteration_is_done) state_r <= eLoadCrypt; else state_r <= eEvaKey;
            eLoadCrypt: state_r <= eCrypt;
            eCrypt: if(iteration_is_done) state_r <= eReverse; else state_r <= eCrypt;
            eReverse: if(need_check) state_r <= eDecrypt; else state_r <= eDone;
            eDecrypt: if(iteration_is_done) state_r <= eRepReverse; else state_r <= eDecrypt;
            eRepReverse: state_r <= eCheck;
            eCheck: 
                if(check_is_match)
                     state_r <= eDone; 
                else //VCS coverage off
                    state_r <= eLoadCrypt;
            eDone: if(yumi_i) state_r <= eIdle;
            default: begin //VCS coverage off
                state_r <= eIdle;
            end
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
            eDecrypt: state_cnt_r <= state_cnt_n;
            default: state_cnt_r <= '0;
        endcase
    end

    reg [group_size_p-1:0] content_r;
    reg [group_size_p-1:0] result_r;
    reg check_is_on_r;
    assign need_check = check_is_on_r;

    reg [3:0][word_width_p-1:0] sfr_r; // register containing current operand to perform turn keys
    wire [group_size_p-1:0] xor_res = sfr_r ^ key_xor_mask_p;
    wire [word_width_p-1:0] turn_transform_res;

    logic [word_width_p-1:0] mask_n;
    reg [3:0][word_width_p-1:0] mask_r;
    wire [group_size_p-1:0] sfr_n = {sfr_r[0] ^ mask_r[0], sfr_r[1] ^ mask_r[1], sfr_r[2] ^ mask_r[2], sfr_r[3] ^ mask_r[3]};

    wire [word_width_p-1:0] mask_input = random_i & {word_width_p{check_is_on_r}};

    always_ff @(posedge clk_i) begin
        if(reset_i) begin
            sfr_r <= '0; 
        end
        else unique case(state_r)
            eIdle: if(v_i) sfr_r <= key_i;
            eCheckKey: sfr_r <= xor_res;
            eEvaKey: sfr_r <= {turn_transform_res ,sfr_r[3:1]};
            eLoadCrypt: sfr_r <= content_r ^ {mask_input, 96'b0};
            eCrypt: sfr_r <= {turn_transform_res, sfr_r[3:1]};
            eReverse: sfr_r <= {sfr_r[0], sfr_r[1], sfr_r[2], sfr_r[3]};
            eDecrypt: sfr_r <= {turn_transform_res, sfr_r[3:1]};
            eRepReverse: sfr_r <= sfr_n;
            default: begin

            end
        endcase
    end

    // Update for result_r, check_is_on_r and content_r.
    always_ff @(posedge clk_i) begin
        if(reset_i) begin
            content_r <= '0;
            result_r <= '0;
            check_is_on_r <= '0;
        end
        else unique case(state_r)
            eIdle: if(v_i) begin
                content_r <= content_i;
                result_r <= '0;
                check_is_on_r <= protection_v_i;
            end
            eReverse: begin
                result_r <= sfr_n;
            end
            default: begin

            end
        endcase
    end

    // Update for check_is_match
    always_comb unique case(state_r)
        eCheck: begin
            check_is_match = (sfr_r == content_r);
        end
        default: begin
            check_is_match = '0;
        end
    endcase

    wire [word_width_p-1:0] mask_li = mask_r[3] ^ mask_r[2] ^ mask_r[1];

    // Update for mask_r[3]
    always_ff @(posedge clk_i) begin
        if(reset_i) begin
            mask_r[3] <= '0;
        end
        else unique case(state_r)
            eCheckKey: begin
                mask_r[3] <= '0;
            end
            eLoadCrypt: begin
                mask_r[3] <= mask_input;
            end
            eCrypt: begin
                mask_r[3] <= mask_n;
            end
            eReverse: begin
                mask_r[3] <= mask_r[0];
            end
            eDecrypt: begin
                mask_r[3] <= mask_n;
            end
            default: begin
                
            end
        endcase
    end

    // Update for mask[2:0]
    always_ff @(posedge clk_i) begin
        if(reset_i) begin
            mask_r[2] <= '0;
            mask_r[1] <= '0;
            mask_r[0] <= '0;
        end
        else unique case(state_r)
            eCrypt: begin
                mask_r[2] <= mask_r[3];
                mask_r[1] <= mask_r[2];
                mask_r[0] <= mask_r[1];
            end
            eReverse: begin
                mask_r[0] <= mask_r[3];
                mask_r[1] <= mask_r[2];
                mask_r[2] <= mask_r[1];
            end
            eDecrypt: begin
                mask_r[2] <= mask_r[3];
                mask_r[1] <= mask_r[2];
                mask_r[0] <= mask_r[1];
            end
            default: begin
                mask_r[2] <= '0;
                mask_r[1] <= '0;
                mask_r[0] <= '0;
            end
        endcase
    end

    logic [word_width_p-1:0] turn_rkeys;

    turn_transform turn (
        .i(sfr_r)
        ,.is_key_i(state_r == eEvaKey)
        ,.rkey_i(turn_rkeys)
        ,.mask_i(mask_li)
        ,.dismask_i(mask_r[0])
        ,.o(turn_transform_res)
        ,.mask_o(mask_n)
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
        else if(state_r == eReverse && need_check) decode_r <= ~decode_r;
        else if(state_r == eRepReverse) decode_r <= decode_r;
    end

    // Cache used for storing keys.
    key_cache #(
        .enabled_p(cache_is_enabled_p)
    ) cache (
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
    assign crypt_o = result_r;
    assign v_o = state_r == eDone;

endmodule

