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
    import sm4_encryptor::*;
(
    input [group_size_p-1:0] i
    ,input is_key_i // Whether i is key. Because rolling shifting is different for key and content.
    ,input [word_width_p-1:0] rkey_i
    ,output [word_width_p-1:0] o

    ,input testing_clk_i // This port is used for driving always block. When public, this port should be deleted.
);

// First, folding the input with xoring.

wire [3:0][word_width_p-1:0] xor_tree_0_li;
assign xor_tree_0_li[0] = i[2*word_width_p-1:word_width_p];
assign xor_tree_0_li[1] = i[3*word_width_p-1:2*word_width_p];
assign xor_tree_0_li[2] = i[4*word_width_p-1:3*word_width_p];
assign xor_tree_0_li[3] = rkey_i;

wire [word_width_p-1:0] xor_tree_0_lo /*verilator public_flat*/ ;

xor_tree #(
    .width_p(word_width_p)
    ,.size_p(4)
) xor_tree_0 (
    .i(xor_tree_0_li)
    ,.o(xor_tree_0_lo)
);

// Second, SBox replacement with xor_tree_lo.

wire [word_width_p-1:0] sbox_lo;

for (genvar j = 0; j < 4; ++j) begin: SBOX_ARRAY
    sbox_memory sbox_mem (
        .i(xor_tree_0_lo[j*byte_width_p+:byte_width_p])
        ,.o(sbox_lo[j*byte_width_p+:byte_width_p])
    );
end

// Third, rolling shifting and gathering sbox_lo.

wire [1:0] [word_width_p-1:0] rkey_shift;

rolling_shifting_group#(
    .width_p(word_width_p)
    ,.size_p(2)
    ,.shift_number_p({32'd13, 32'd23})
) rsg_key (
    .i(sbox_lo)
    ,.o(rkey_shift)
);

wire [3:0][word_width_p-1:0] content_shift;

rolling_shifting_group#(
    .width_p(word_width_p)
    ,.size_p(4)
    ,.shift_number_p({32'd2, 32'd10, 32'd18, 32'd24})
) rsg_con (
    .i(sbox_lo)
    ,.o(content_shift)
);

wire [5:0][word_width_p-1:0] sel_shift;

for(genvar j = 0; j < 4; ++j) begin
    if(j < 2)
        assign sel_shift[j] = is_key_i ? rkey_shift[j] : content_shift[j];
    else
        assign sel_shift[j] = is_key_i ? '0 :content_shift[j];
end

assign sel_shift[4] = i[word_width_p-1:0];
assign sel_shift[5] = sbox_lo;

xor_tree #(
    .width_p(word_width_p)
    ,.size_p(6)
) final_xor (
    .i(sel_shift)
    ,.o(o)
);

always_ff @(posedge testing_clk_i) begin
    $display("xor_tree_0_lo:%b",xor_tree_0_lo);
    $display("sbox_lo:%b",sbox_lo);
    $display("rkey_shift:%b",rkey_shift);
    $display("content_shift:%b",content_shift);
    $display("sel_shift:%b",sel_shift);
    $display("o:%b",o);
end

endmodule




module rolling_shifting_group
#(
    parameter integer width_p = "inv"
    ,parameter integer size_p = "inv"
    ,parameter logic [size_p-1:0][31:0] shift_number_p = '0
)(
    input [width_p-1:0] i
    ,output [size_p-1:0][width_p-1:0] o
);
    for(genvar j = 0; j < size_p; ++j) begin: SHIFTER
        roll_shifter #(
            .width_p(width_p)
            ,.shift_num_p(shift_number_p[j])
            ,.left_shifted_p(1'b1)
        ) sfter (
            .i(i)
            ,.o(o[j][width_p-1:0])
        );
    end
endmodule
