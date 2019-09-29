// -------------------------------------------------------
// -- random_mask.sv
// -------------------------------------------------------
// This module generates random number (8bit) with cycle = 2^32.
// The feedback function is x^32 + x^22 + x^2 + x + 1
// -------------------------------------------------------

module random_mask(
    input clk_i
    ,input reset_i

    ,input load_i
    ,input [31:0] load_n_i

    ,output [31:0] o
);
    reg [31:0] mask_r;
    wire [31:0] mask_n;
    always_ff @(posedge clk_i) begin
        if(reset_i) mask_r <= '0;
        else if(load_i) mask_r <= load_n_i;
        else mask_r <= mask_n;
    end

    assign mask_n = {mask_r[0],mask_r[31:1]} ^ {9'b0, mask_r[0], 19'b0, mask_r[0], mask_r[0], 1'b0};
    assign o = mask_r;
    
endmodule
