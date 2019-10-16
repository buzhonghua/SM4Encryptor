`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

import "DPI-C" function void encryption(input bit [group_size_p-1:0] key, input bit [group_size_p-1:0] value, input bit decode, output bit [group_size_p-1:0] crypt);

class sm4_crypt_transaction extends uvm_sequence_item;
    rand bit [group_size_p-1:0] key;
    rand bit [group_size_p-1:0] content;
    rand bit decode;

    bit [group_size_p-1:0] expected_crypt;

    function void post_randomize();
        encryption(key, content, decode, expected_crypt);
    endfunction

    `uvm_object_utils(sm4_crypt_transaction);

    function new(string name = "sm4_crypt_transaction");
        super.new(name);
    endfunction

    function display();
        $display("==================== Transaction INFO ===================");
        $display("key:%h", key);
        $display("content:%h", content);
        $display("decode:%b", decode);
        $display("expected_crypt:%h", expected_crypt);
    endfunction

endclass
