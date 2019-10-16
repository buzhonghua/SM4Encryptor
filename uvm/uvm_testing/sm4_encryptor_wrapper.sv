
// -------------------------------------------------------
// -- sm4_encryptor_wrapper.sv
// -------------------------------------------------------
// This is a wrapper for top module of sm4_encryptor, with purpose of UVM facilities.
// -------------------------------------------------------

module sm4_encryptor_wrapper
    import sm4_encryptor_pkg::*;
(
    sm4_encryptor_if ifc
);

sm4_encryptor core(
    .clk_i(ifc.clk_i)
    ,.reset_i(ifc.reset_i)
    ,.content_i(ifc.content_i)
    ,.key_i(ifc.key_i)
    ,.encode_or_decode_i(ifc.encode_or_decode_i)
    ,.v_i(ifc.v_i)
    ,.ready_o(ifc.ready_o)
    ,.crypt_o(ifc.crypt_o)
    ,.v_o(ifc.v_o)
    ,.yumi_i(ifc.yumi_i)
    ,.invalid_cache_i(ifc.invalid_cache_i)
);

assign ifc.state_o = core.state_r;
assign ifc.state_cnt_o = core.state_cnt_r;
assign ifc.sfr_o = core.sfr_r;
assign ifc.replace_which_o = core.cache.to_replace;
assign ifc.selected_o = core.cache.selected_n;
assign ifc.cache_is_missed_o = core.cache_is_miss;

endmodule
