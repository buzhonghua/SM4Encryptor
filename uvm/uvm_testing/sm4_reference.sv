`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;
import "DPI-C" function void encryption(input bit [group_size_p-1:0] key, input bit [group_size_p-1:0] value, input bit decode, output bit [group_size_p-1:0] crypt);

class sm4_reference extends uvm_component;

    uvm_blocking_get_port #(sm4_crypt_transaction) port;
    uvm_analysis_port #(sm4_check_transaction) ap;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

    `uvm_component_utils(sm4_reference);

endclass


function sm4_reference::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void sm4_reference::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this);
   ap = new("ap", this);
endfunction

task sm4_reference::main_phase(uvm_phase phase);
    sm4_crypt_transaction get_tr;
    sm4_check_transaction put_tr;
    super.main_phase(phase);
    while(1) begin
        port.get(get_tr);
        put_tr = new("put_tr");
        encryption(get_tr.key, get_tr.content, get_tr.decode, put_tr.expected_crypt);
        //`uvm_info("sm4_reference", "get one transaction, evaluate the expected output:", UVM_LOW);
        ap.write(put_tr);
    end
endtask