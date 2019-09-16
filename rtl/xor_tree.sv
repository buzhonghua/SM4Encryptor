// -------------------------------------------------------
// -- xor_tree.sv
// -------------------------------------------------------
// This module exclusively ors 4 inputs number with tree structure.
// -------------------------------------------------------


module xor_tree #(
    parameter integer width_p = "inv"
)(
    input [3:0][width_p-1:0] i,
    output [width_p-1:0] o
);

wire [width_p-1:0] sub1 = i[0] ^ i[1];
wire [width_p-1:0] sub2 = i[2] ^ i[3];

assign o =  sub1 ^ sub2;

endmodule
