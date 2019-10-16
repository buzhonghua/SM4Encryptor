`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class base_test extends uvm_test;

   sm4_env env;
   
   function new(string name = "base_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   
   `uvm_component_utils(base_test);

endclass


function void base_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
   env = sm4_env::type_id::create("env", this); 
endfunction

function void base_test::report_phase(uvm_phase phase);
   uvm_report_server server;
   int err_num;
   super.report_phase(phase);

   server = get_report_server();
   err_num = server.get_severity_count(UVM_ERROR);

   if (err_num != 0) begin
      $display("CASE FAILED");
   end
   else begin
      $display("CASE PASSED");
   end
endfunction