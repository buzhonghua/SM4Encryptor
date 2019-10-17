`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class sm4_monitor extends uvm_monitor;
    virtual sm4_encryptor_if vif;
    `uvm_component_utils(sm4_monitor);
    uvm_analysis_port #(sm4_check_transaction) ap;

    function new(string name="sm4_monitor", uvm_component parent);
        super.new(name, parent);
        output_cvr = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual sm4_encryptor_if)::get(this, "", "vif", vif))
            `uvm_fatal("sm4_monitor", "virtual interface must be set for vif!");
        ap = new("ap", this);
    endfunction

    task main_phase(uvm_phase phase);
        sm4_check_transaction trans;
        //phase.raise_objection(this);
        while(1) begin
            trans = new("trans");
            transaction_pack(trans);
            output_cvr.sample(trans);
            ap.write(trans);
        end
        //phase.drop_objection(this);
    endtask

    task transaction_pack(sm4_check_transaction trans);
        @(posedge vif.v_o);
        //`uvm_info("sm4_monitor", "begin to package the transaction", UVM_LOW);
        trans.expected_crypt = vif.crypt_o;
        trans.expected_cycle = vif.cycle_o;
        trans.replace_which = vif.replace_which_o;
        trans.cache_is_miss = vif.cache_is_missed_o;
    endtask

    covergroup output_cvr with function sample(sm4_check_transaction trans);
        coverpoint trans.expected_crypt;
        coverpoint trans.expected_cycle {
            bins miss = {67};
            bins hit = {35};
        }
        coverpoint trans.replace_which;
        coverpoint trans.cache_is_miss;
    endgroup

    virtual function void report_phase(uvm_phase phase);
        $display("Monitor Coverage:%0.2f %%",output_cvr.get_inst_coverage());
    endfunction

endclass
