module expand_to_16bit(
    input wire [127:0] data_in,
    output wire [128 * 16 - 1:0] data_out
);

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : EXP8
            assign data_out[16 * i + 15 -:16] = {data_in[i], 15'b000000000000000};
        end
    endgenerate

endmodule