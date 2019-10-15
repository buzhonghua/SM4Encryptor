// -------------------------------------------------------
// -- priority_encoder.v
// -------------------------------------------------------
// This is a 4 bit encoder used in cache.
// -------------------------------------------------------

module priority_encoder
#(
    parameter bit valid_bit_p = 1
)(
    input [3:0] i
    ,output logic [1:0] o
);
    if(valid_bit_p)
        always_comb unique casez(i)
            4'b???1: o = 2'd0;
            4'b??10: o = 2'd1;
            4'b?100: o = 2'd2;
            4'b1000: o = 2'd3;
            4'b0000: o = 2'd0;
        endcase
    else 
        always_comb unique casez(i)
            4'b???0: o = 2'd0;
            4'b??01: o = 2'd1;
            4'b?011: o = 2'd2;
            4'b0111: o = 2'd3;
            4'b1111: o = 2'd0;
        endcase
endmodule
