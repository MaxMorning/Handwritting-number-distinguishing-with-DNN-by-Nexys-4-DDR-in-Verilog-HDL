parameter bit = 12;
module expand_to_16bit(
    input wire [127:0] data_in,
    output wire [128 * bit - 1:0] data_out
);

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : EXP8
            assign data_out[bit * i + (bit - 1) -:bit] = {data_in[i], {(bit - 1){1'b0}}};
        end
    endgenerate

endmodule