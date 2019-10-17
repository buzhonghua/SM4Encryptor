`include "uvm_macros.svh"

import uvm_pkg::*;


module sm4_test_top
    import sm4_encryptor_pkg::*;
(
    
);

sm4_encryptor_if dut_if();

sm4_encryptor_wrapper dut(
    .ifc(dut_if)
);

initial begin
    uvm_config_db #(virtual sm4_encryptor_if)::set(null, "uvm_test_top.env.driver", "vif", dut_if);
    uvm_config_db #(virtual sm4_encryptor_if)::set(null, "uvm_test_top.env.monitor", "vif", dut_if);
    uvm_coreservice_t::get().get_root().set_timeout(1000000ns);
    run_test("sm4_case_num");
end


endmodule
