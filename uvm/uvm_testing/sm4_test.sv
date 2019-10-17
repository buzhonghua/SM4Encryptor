`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class sm4_test extends uvm_test;

   sm4_env env;
   
   function new(string name = "sm4_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   
   `uvm_component_utils(sm4_test);

endclass


function void sm4_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
   env = sm4_env::type_id::create("env", this); 
endfunction

function void sm4_test::report_phase(uvm_phase phase);
   uvm_report_server server;
   int err_num;
   super.report_phase(phase);

   server = uvm_coreservice_t::get().get_report_server();
   err_num = server.get_severity_count(UVM_ERROR);

   if (err_num != 0) begin
      $display("CASE FAILED");
   end
   else begin
      $display("CASE PASSED");
   end
endfunction