// -------------------------------------------------------
// -- sm4_encryptor_pkg.svh
// -------------------------------------------------------
// This file defines the constant parameter used for sm4 encryptor.
// -------------------------------------------------------

package sm4_encryptor_pkg;
    
    parameter integer byte_width_p = 8;
    parameter integer word_width_p = 32;
    parameter integer group_size_p = 128;
    parameter integer key_size_p = group_size_p;
    parameter integer turn_key_num_p = 32;


    // These parameters are defined by SM4 Algorithm standard. 
    parameter logic [group_size_p-1:0] key_xor_mask_p = 128'hB27022DC_677D9197_56AA3350_A3B1BAC6;
    parameter logic [31:0][word_width_p-1:0] key_aux_p = {
        32'h646b7279, 32'h484f565d, 32'h2c333a41, 32'h10171e25, 32'hf4fb0209, 32'hd8dfe6ed, 32'hbcc3cad1, 32'ha0a7aeb5, 32'h848b9299, 32'h686f767d, 32'h4c535a61, 32'h30373e45, 32'h141b2229, 32'hf8ff060d, 32'hdce3eaf1, 32'hc0c7ced5, 32'ha4abb2b9, 32'h888f969d, 32'h6c737a81, 32'h50575e65, 32'h343b4249, 32'h181f262d, 32'hfc030a11, 32'he0e7eef5, 32'hc4cbd2d9, 32'ha8afb6bd, 32'h8c939aa1, 32'h70777e85, 32'h545b6269, 32'h383f464d, 32'h1c232a31, 32'h70e15
    };

    typedef enum logic [3:0] {eIdle, eCheckKey, eEvaKey, eLoadCrypt, eCrypt, eReverse, eDecrypt, eRepReverse, eCheck, eDone} state_e;
    
endpackage
