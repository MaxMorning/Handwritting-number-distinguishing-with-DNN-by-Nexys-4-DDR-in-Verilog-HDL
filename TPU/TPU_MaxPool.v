module maxpool(
    input [24 * 24 * 8 - 1:0] tensor_in,

    output [12 * 12 * 8 - 1:0] tensor_out
);

    genvar row, col;
    generate
        for (row = 0; row < 12; row = row + 1) begin : ROWS
            for (col = 0; col < 12; col = col + 1) begin : COLUMN
                max_in_4 inst(
                    .data_in({
                        tensor_in[((2 * row + 1) * 24 + (2 * col + 1)) * 8 + 7 -: 16],
                        tensor_in[((2 * row) * 24 + (2 * col + 1)) * 8 + 7 -: 16]
                    }),
                    .data_max(tensor_out[(row * 12 + col) * 8 + 7 -: 8])
                );
            end
        end
    endgenerate
endmodule