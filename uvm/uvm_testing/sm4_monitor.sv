`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class sm4_monitor extends uvm_monitor;
    virtual sm4_encryptor_if vif;
    `uvm_component_utils(sm4_monitor)
    function new(string name="sm4_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual sm4_encryptor_if)::get(this, "", "vif", vif))
            `uvm_fatal("sm4_monitor", "virtual interface must be set for vif!");
    endfunction

    task main_phase(uvm_phase phase);
        super.main_phase(phase);
        phase.raise_objection(this);
        for(int i = 0; i < 32; ++i) begin
            gatherAndCompare();
        end
        phase.drop_objection(this);
    endtask

    task gatherAndCompare();
        sm4_crypt_transaction trans;
        @(posedge vif.v_o);
        trans = new("sm4_crypt_transaction");
        trans.key = vif.key_i;
        trans.content = vif.content_i;
        trans.decode = vif.encode_or_decode_i;

        trans.evaluate_expectation();

        if(trans.expected_crypt != vif.crypt_o) begin    
            trans.display();
            $display("actual_output:%h", vif.crypt_o);
            `uvm_info("sm4_monitor", "mismatch!", UVM_LOW);
        end
        else begin
            `uvm_info("sm4_monitor", "passed!", UVM_LOW);
        end

    endtask

endclass
