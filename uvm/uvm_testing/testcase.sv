`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class case_num extends uvm_sequence #(sm4_crypt_transaction);
   sm4_crypt_transaction tr;

   function  new(string name= "case_num");
      super.new(name);
   endfunction 
   
   virtual task body();
     //Code here
     repeat (32) begin
        `uvm_do(tr);
     end
   endtask

   `uvm_object_utils(case_num);
endclass


class sm4_case_num extends sm4_test;

   function new(string name = "sm4_case_num", uvm_component parent = null);
      super.new(name,parent);
   endfunction 

   extern virtual function void build_phase(uvm_phase phase); 
   `uvm_component_utils(sm4_case_num);
endclass


function void sm4_case_num::build_phase(uvm_phase phase);
   super.build_phase(phase);
   uvm_config_db#(uvm_object_wrapper)::set(this, "env.sequencer.main_phase", "default_sequence", case_num::type_id::get());
endfunction