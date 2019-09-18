// -------------------------------------------------------
// -- xor_tree.sv
// -------------------------------------------------------
// This module exclusively ors N elements.
// -------------------------------------------------------


module xor_tree #(
    parameter integer width_p = "inv"
    ,parameter integer size_p = "inv"
)(
    input [size_p-1:0][width_p-1:0] i
    ,output [width_p-1:0] o
);

localparam actual_capacity_lp = 1 << $clog2(size_p);

wire [2*actual_capacity_lp-2:0][width_p-1:0] tree_ipt;

for(genvar j = 0; j < actual_capacity_lp-1; ++j) begin
    assign tree_ipt[j] = tree_ipt[2*j+1] ^ tree_ipt[2*j+2];
end

for(genvar j = 0; j < actual_capacity_lp; ++j) begin
    if(j < size_p) 
        assign tree_ipt[actual_capacity_lp-1+j] = i[j];
    else 
        assign tree_ipt[actual_capacity_lp-1+j] = '0;
end

assign o = tree_ipt[0];


endmodule
