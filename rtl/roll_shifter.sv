// -------------------------------------------------------
// -- roll_shifter.sv 
// -------------------------------------------------------
// This module provides rolling shifting with static parameter.
// -------------------------------------------------------


module roll_shifter #(
    parameter integer width_p = "inv"
    ,parameter logic [$clog2(width_p)-1:0] shift_num_p = "inv"
    ,parameter bit left_shifted_p = 1
)(
    input [width_p-1:0] i
    ,output [width_p-1:0] o
);

for (genvar j = 0; j < width_p; j++) begin: SHIFTER_BITS
    if (left_shifted_p == 0) // right shifted
        assign o[j] = i[(j + shift_num_p) % width_p];
    else
        assign o[j] = i[(j - shift_num_p + width_p) % width_p];
end

/*
if(left_shifted_p)
    assign o = {i[width_p-1-shift_num_p:0],i[width_p-1-:shift_num_p]};
else
    assign o = {i[shift_num_p-1:0],i[width_p-1:shift_num_p]};
*/
endmodule
