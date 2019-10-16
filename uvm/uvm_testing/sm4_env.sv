`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class sm4_env extends uvm_env;
    `uvm_component_utils(sm4_env);

    sm4_driver driver;
    sm4_monitor monitor;

    function new(string name="sm4_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = sm4_driver::type_id::create("sm4_driver", this);
        monitor = sm4_monitor::type_id::create("sm4_monitor", this);
    endfunction
endclass