// -------------------------------------------------------
// -- turn_transform.sv
// -------------------------------------------------------
// This module performs transformations in one turns, which includes:
// 1. XOR folding, from 128bit to 32bit.
// 2. SBox transformation on 32bit.
// 3. Rolling shifting.
// 4. Xor gathering. 
// -------------------------------------------------------

module turn_transform 
    import sm4_encryptor;
(
    input [group_size_p-1:0] i,
    input is_key_i, // Whether i is key. Because rolling shifting is different for key and content.
    input [word_width_p-1:0] rkey_i
    
    output [word_width_p-1:0] o
);

// First, folding the input with xoring.

wire [3:0][word_width_p-1:0] xor_tree_0_li;
assign xor_tree_0_li[0] = i[2*word_width_p-1:word_width_p];
assign xor_tree_0_li[1] = i[3*word_width_p-1:2*word_width_p];
assign xor_tree_0_li[2] = i[4*word_width_p-1:3*word_width_p];
assign xor_tree_0_li[3] = rkey_i;

wire [word_width_p-1:0] xor_tree_0_lo;

xor_tree #(
    .width_p(word_width_p)
) xor_tree_0 (
    .i(xor_tree_0_li),
    .o(xor_tree_lo)
);

// Second, SBox replacement with xor_tree_lo.

wire [word_width_p-1:0] sbox_lo;

for (genvar j = 0; j < 4; ++i) begin: SBOX_ARRAY
    sbox_memory sbox_mem (
        .i(xor_tree_lo[j*byte_width_p+:byte_width_p])
        .o(sbox_lo[j*byte_width_p+:byte_width_p])
    );
end

// Third, rolling shifting and gathering sbox_lo.



endmodule


module rolling_shifting_and_gathering
#(
    parameter integer width_p = "inv",
    parameter integer shift_number_p[4] = {0,0,0,0}
)(
    input [width_p-1:0] i,
    output [width_p-1:0] o
);
    wire [3:0][width_p-1:0] sft_res;
    for(genvar j = 0; j < 4; ++j) begin: SHIFTER
        roll_shifter #(
            .width_p(width_p),
            .shift_number_p(shift_number_p[j]),
            .left_shifted_p(1'b1)
        ) sfter (
            .i(i),
            .o(sft_res[j])
        );
    end

    xor_tree #(
        .width_p(width_p)
    ) xor_tree_0 (
        .i(sft_res),
        .o(o)
    );

endmodule
