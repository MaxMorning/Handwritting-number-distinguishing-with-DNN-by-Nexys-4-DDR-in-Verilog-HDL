module expand_to_8bit(
    input wire [127:0] data_in,
    output wire [128 * 8 - 1:0] data_out
);

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : EXP8
            assign data_out[8 * i + 7 -:8] = {data_in[i], 7'b0000000};
        end
    endgenerate

endmodule