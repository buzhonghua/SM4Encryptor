`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class sm4_sequencer extends uvm_sequencer #(sm4_crypt_transaction);
   
    `uvm_component_utils(sm4_sequencer);

   function new(string name = "sm4_sequencer", uvm_component parent);
      super.new(name, parent);
   endfunction
   
endclass