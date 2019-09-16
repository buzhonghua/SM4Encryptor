// -------------------------------------------------------
// -- sm4_encryptor.svh
// -------------------------------------------------------
// This file defines the constant parameter used for sm4 encryptor.
// -------------------------------------------------------

package sm4_encryptor;
    
    parameter integer byte_width_p = 8;
    parameter integer word_width_p = 32;
    parameter integer group_size_p = 128;
    parameter integer key_size_p = group_size_p;

    
endpackage
