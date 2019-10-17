`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class sm4_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(sm4_scoreboard);
    uvm_blocking_get_port #(sm4_check_transaction)  expect_port;
    uvm_blocking_get_port #(sm4_check_transaction)  actual_port;
    sm4_check_transaction check_queue[$];

    extern function new(string name, uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

endclass

function sm4_scoreboard::new(string name, uvm_component parent = null);
   super.new(name, parent);
endfunction 

function void sm4_scoreboard::build_phase(uvm_phase phase);
   super.build_phase(phase);
   expect_port = new("expect_port", this);
   actual_port = new("actual_port", this);
endfunction 

task sm4_scoreboard::main_phase(uvm_phase phase);
    sm4_check_transaction get_expect, get_actual, get_queue;
    bit result;
    phase.raise_objection(this);
    super.main_phase(phase);
    fork
        while(1) begin
            expect_port.get(get_expect);
            check_queue.push_back(get_expect);
        end
        while(1) begin
            actual_port.get(get_actual);
            if(check_queue.size() > 0) begin
                get_queue = check_queue.pop_front();
                result = get_actual.compare(get_queue);
                if(result) begin
                    `uvm_info("sm4_scoreboard", "passed!", UVM_LOW);
                end
                else begin
                    `uvm_info("sm4_scoreboard", "mismatch!", UVM_LOW);
                end
            end
            else begin
                `uvm_error("sm4_scoreboard", "unexpected output from DUT cause there's no output from Reference");
            end
        end
    join
    phase.drop_objection(this);

endtask