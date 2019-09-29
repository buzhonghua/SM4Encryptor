// -------------------------------------------------------
// -- lru_recorder.sv
// -------------------------------------------------------
// This file defines the module for recording LUR bits of 4 items.
// -------------------------------------------------------

module lru_recorder(
    input clk_i
    ,input reset_i

    ,input [1:0] access1_i
    ,input v1_i

    ,input [1:0] access2_i
    ,input v2_i

    ,output logic [1:0] replace_which_o
);

    reg [3:0][3:0] matrix_r;

    for(genvar i = 0; i < 4; ++i) begin
        for(genvar j = 0; j < 4; ++j) begin
            always_ff @(posedge clk_i) begin
                if(reset_i) matrix_r[i][j] <= '0;
                else if(v1_i) begin
                    if(access1_i == j)
                        matrix_r[i][j] <= 1'b0;
                    else if(access1_i == i)
                        matrix_r[i][j] <= 1'b1;
                end
                else if(v2_i) begin
                    if(access2_i == j)
                        matrix_r[i][j] <= 1'b0;
                    else if(access2_i == i)
                        matrix_r[i][j] <= 1'b1;
                end
            end
        end
    end

    wire [3:0] row_is_zero;
    for(genvar i = 0; i < 4; ++i)
        assign row_is_zero[i] = matrix_r[i] == '0;
    
    priority_encoder encoder(
        .i(row_is_zero)
        ,.o(replace_which_o)
    );
    
endmodule

