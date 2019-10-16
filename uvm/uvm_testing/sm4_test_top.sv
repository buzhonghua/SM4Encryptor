`include "uvm_macros.svh"

import uvm_pkg::*;


module sm4_test_top
    import sm4_encryptor_pkg::*;
(
    
);


logic clk_li;
logic reset_li;

sm4_encryptor_if dut_if();

assign dut_if.clk_i = clk_li;
assign dut_if.reset_i = reset_li;


sm4_encryptor_wrapper dut(
    .ifc(dut_if)
);

initial begin
    uvm_config_db #(virtual sm4_encryptor_if)::set(null, "uvm_test_top", "vif", dut_if);
    run_test("sm4_driver");
end


endmodule
