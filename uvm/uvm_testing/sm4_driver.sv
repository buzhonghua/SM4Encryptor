`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;


class sm4_driver extends uvm_driver#(sm4_crypt_transaction);

    virtual sm4_encryptor_if vif;
    `uvm_component_utils(sm4_driver);

    uvm_analysis_port #(sm4_crypt_transaction) ap;

    function new(string name="sm4_driver", uvm_component parent = null);
        super.new(name, parent);
        input_cvr = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual sm4_encryptor_if)::get(this, "", "vif", vif))
            `uvm_fatal("sm4_driver", "virtual interface must be set for vif!");
        ap = new("ap", this);
    endfunction

    extern virtual task main_phase(uvm_phase phase);

    extern virtual task encrypt(sm4_crypt_transaction trans);
    extern virtual task reset();
    extern virtual task invalid_cache();
    extern virtual task tick();

    extern virtual task reset_test();

    covergroup input_cvr with function sample(sm4_crypt_transaction trans);
        coverpoint trans.decode{
            bins decode = {1};
            bins encode = {1};
        }
        coverpoint trans.content;
        coverpoint trans.key;
    endgroup

    virtual function void report_phase(uvm_phase phase);
        $display("Driver Coverage:%0.2f %%",input_cvr.get_inst_coverage());
    endfunction

endclass


task sm4_driver::main_phase(uvm_phase phase);
    //phase.raise_objection(this);
    reset();
    reset_test();
    while(1) begin
        seq_item_port.get_next_item(req);
        input_cvr.sample(req);
        ap.write(req);
        encrypt(req);
        seq_item_port.item_done();
    end
    //phase.drop_objection(this);
endtask

task sm4_driver::tick();
    vif.clk_i = 1'b1;
    #1
    vif.clk_i = 1'b0;
    #1;
endtask

task sm4_driver::reset();
    vif.reset_i = 1'b1;
    #1
    vif.clk_i = 1'b1;
    #1
    vif.reset_i = 1'b0;
    #1
    vif.clk_i = 1'b0;
endtask

task sm4_driver::invalid_cache();
    vif.invalid_cache_i = 1'b1;
    tick();
    vif.invalid_cache_i = 1'b0;
    tick();
endtask


task sm4_driver::encrypt(sm4_crypt_transaction trans);
    int result = 0;
    // set value to interface.
    vif.content_i = trans.content;
    vif.key_i = trans.key;
    vif.encode_or_decode_i = trans.decode;
    vif.v_i = 1'b1;
    while(vif.v_o == 0) begin
        tick();
        result++;
    end
    tick();
    vif.yumi_i = 1'b1;
    tick();
    vif.v_i = 1'b0;
    vif.yumi_i = 1'b0;
    tick();

//    cycle = result;
endtask


task sm4_driver::reset_test();
    vif.v_i = 1'b1;
    vif.content_i = '0;
    vif.key_i = '0;
    for(int i = 0; i < 68; ++i) begin
        for(int j = 0; j < i; ++j) begin
            tick();
        end
        reset();
    end
    vif.v_i = 1'b0;
endtask

