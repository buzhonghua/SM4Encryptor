`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;


class sm4_check_transaction extends uvm_sequence_item;
    bit [group_size_p-1:0] expected_crypt;

    function void post_randomize();
        
    endfunction

    `uvm_object_utils_begin(sm4_check_transaction)
        `uvm_field_int(expected_crypt,UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name = "sm4_check_transaction");
        super.new(name);
    endfunction

    function display();
        $display("==================== Check Transaction INFO ===================");
        $display("expected_crypt:%h", expected_crypt);
    endfunction

endclass
