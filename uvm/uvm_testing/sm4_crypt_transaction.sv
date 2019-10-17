`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;


class sm4_crypt_transaction extends uvm_sequence_item;
    rand bit [group_size_p-1:0] key;
    rand bit [group_size_p-1:0] content;
    rand bit decode;
    rand bit enable_mask;


    function void post_randomize();
        
    endfunction


    function random_content();
        content = {$random, $random, $random, $random};
    endfunction

    `uvm_object_utils_begin(sm4_crypt_transaction)
        `uvm_field_int(key,UVM_ALL_ON)
        `uvm_field_int(content,UVM_ALL_ON)
        `uvm_field_int(decode,UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name = "sm4_crypt_transaction");
        super.new(name);
    endfunction

    function display();
        $display("==================== Crypt Transaction INFO ===================");
        $display("key:%h", key);
        $display("content:%h", content);
        $display("decode:%b", decode);
        $display("enable_mask:%b", enable_mask);
    endfunction

endclass
