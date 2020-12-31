module conv1(
    input [28 * 28 * 8 - 1:0] tensor_in,
    input [25 * 8 - 1:0] filter_in,
    input [7:0] bias_in,

    output [24 * 24 * 8 - 1:0] tensor_out,
    output overflow
);

    wire [24 * 24 * 2 - 1:0] overflows;
    wire [24 * 24 * 8 - 1:0] conv_out;
    genvar rowCnt,colCnt;

    generate
        for (rowCnt = 0; rowCnt < 24; rowCnt = rowCnt + 1)
            for (colCnt = 0; colCnt < 24; colCnt = colCnt + 1) begin
                TPU_Conv_25(
                    .data_in1({tensor_in[(rowCnt * 28 + colCnt) * 8 + 7:(rowCnt * 28 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 28 + 28 + colCnt) * 8 + 7:(rowCnt * 28 + 28 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 28 + 2 * 28 + colCnt) * 8 + 7:(rowCnt * 28 + 2 * 28 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 28 + 3 * 28 + colCnt) * 8 + 7:(rowCnt * 28 + 3 * 28 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 28 + 4 * 28 + colCnt) * 8 + 7:(rowCnt * 28 + 4 * 28 + colCnt + 4) * 8]}),
                    .data_in2(filter_in),

                    .data_out(conv_out[(rowCnt * 24 + colCnt) * 8 + 7:(rowCnt * 24 + colCnt) * 8]),
                    .overflow(overflows[rowCnt * 24 + colCnt])
                );

                Float8Adder(
                    .iNum1(conv_out[(rowCnt * 24 + colCnt) * 8 + 7:(rowCnt * 24 + colCnt) * 8]),
                    .iNum2(bias_in),

                    .oNum(tensor_out[(rowCnt * 24 + colCnt) * 8 + 7:(rowCnt * 24 + colCnt) * 8])
                    .overflow(24 * 24 + rowCnt * 24 + colCnt)
                );
            end
    endgenerate

    assign overflow = | overflows;
endmodule