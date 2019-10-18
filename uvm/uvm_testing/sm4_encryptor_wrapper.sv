
// -------------------------------------------------------
// -- sm4_encryptor_wrapper.sv
// -------------------------------------------------------
// This is a wrapper for top module of sm4_encryptor, with purpose of UVM facilities.
// -------------------------------------------------------

module sm4_encryptor_wrapper
    import sm4_encryptor_pkg::*;
#(
    parameter bit cache_is_enabled_p = 1
)(
    sm4_encryptor_if ifc
);

sm4_encryptor #(
    .cache_is_enabled_p(cache_is_enabled_p)
) core(
    .clk_i(ifc.clk_i)
    ,.reset_i(ifc.reset_i)
    ,.content_i(ifc.content_i)
    ,.key_i(ifc.key_i)
    ,.random_i(ifc.random_i)
    ,.encode_or_decode_i(ifc.encode_or_decode_i)
    ,.v_i(ifc.v_i)
    ,.ready_o(ifc.ready_o)
    ,.crypt_o(ifc.crypt_o)
    ,.v_o(ifc.v_o)
    ,.yumi_i(ifc.yumi_i)
    ,.invalid_cache_i(ifc.invalid_cache_i)
    ,.protection_v_i(ifc.protection_v_i)
);

//assign ifc.replace_which_o = core.cache.to_replace;
//assign ifc.cache_is_missed_o = core.cache_is_miss;
if(cache_is_enabled_p) begin
    reg [1:0] replace_which_r;
    reg cache_is_missed_r;

    always @(posedge ifc.clk_i) begin
        if(ifc.reset_i) begin
            replace_which_r <= '0;
            cache_is_missed_r <= '0;
        end
        else unique case(core.state_r) 
            eIdle: if(ifc.v_i) begin
                replace_which_r <= '0;
                cache_is_missed_r <= '0;
            end
            eCheckKey: begin
                cache_is_missed_r <= core.cache_is_miss;
                replace_which_r <= core.cache.ENABLE_CACHE.to_replace;
            end
            default: begin

            end
        endcase
    end
    assign ifc.replace_which_o = replace_which_r;
    assign ifc.cache_is_missed_o = cache_is_missed_r;
end
else begin
    assign ifc.replace_which_o = 2'b00;
    assign ifc.cache_is_missed_o = 1'b1;
end

reg [31:0] cycle_r;

always @(posedge ifc.clk_i) begin
    if(ifc.reset_i) cycle_r <= '0;
    else unique case(core.state_r) 
        eIdle: if(ifc.v_i) begin
            cycle_r <= '0;
        end
        default: begin
            cycle_r <= cycle_r + 1;
        end
        eDone: begin
            
        end
    endcase
end

assign ifc.cycle_o = cycle_r;


endmodule
