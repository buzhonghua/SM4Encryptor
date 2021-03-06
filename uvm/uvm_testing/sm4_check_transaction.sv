`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;


class sm4_check_transaction extends uvm_sequence_item;
    bit [group_size_p-1:0] expected_crypt;
    bit [7:0] expected_cycle;
    bit [1:0] replace_which;
    bit cache_is_miss;
    bit protection;

    function void post_randomize();
        
    endfunction

    `uvm_object_utils_begin(sm4_check_transaction)
        `uvm_field_int(expected_crypt,UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name = "sm4_check_transaction");
        super.new(name);
    endfunction

    function int get_expected_cycle();
        int res = 0;
        if(cache_is_miss) res = 67;
        else res = 35;
        if(protection) res += 34;
        return expected_cycle;
    endfunction

    function display();
        $display("==================== Check Transaction INFO ===================");
        $display("expected_crypt:%h", expected_crypt);
        $display("expected_cycle:%d", expected_cycle);
        $display("replace_which:%d", replace_which);
        $display("cache_is_miss:%d", cache_is_miss);
    endfunction

endclass
