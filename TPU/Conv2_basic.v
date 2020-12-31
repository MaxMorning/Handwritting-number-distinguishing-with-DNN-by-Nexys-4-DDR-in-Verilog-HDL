module conv2(
    input [12 * 12 * 8 - 1:0] tensor_in,
    input [25 * 8 - 1:0] filter_in,
    input [7:0] bias_in,

    output [8 * 8 * 8 - 1:0] tensor_out,
    output overflow
);

    wire [8 * 8 * 2 - 1:0] overflows;
    wire [8 * 8 * 8 - 1:0] conv_out;
    genvar rowCnt,colCnt;

    generate
        for (rowCnt = 0; rowCnt < 8; rowCnt = rowCnt + 1)
            for (colCnt = 0; colCnt < 8; colCnt = colCnt + 1) begin
                TPU_Conv_25(
                    .data_in1({tensor_in[(rowCnt * 12 + colCnt) * 8 + 7:(rowCnt * 12 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 12 + 12 + colCnt) * 8 + 7:(rowCnt * 12 + 12 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 12 + 2 * 12 + colCnt) * 8 + 7:(rowCnt * 12 + 2 * 12 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 12 + 3 * 12 + colCnt) * 8 + 7:(rowCnt * 12 + 3 * 12 + colCnt + 4) * 8],
                                tensor_in[(rowCnt * 12 + 4 * 12 + colCnt) * 8 + 7:(rowCnt * 12 + 4 * 12 + colCnt + 4) * 8]}),
                    .data_in2(filter_in),

                    .data_out(conv_out[(rowCnt * 8 + colCnt) * 8 + 7:(rowCnt * 8 + colCnt) * 8]),
                    .overflow(overflows[rowCnt * 8 + colCnt])
                );

                Float8Adder(
                    .iNum1(conv_out[(rowCnt * 8 + colCnt) * 8 + 7:(rowCnt * 8 + colCnt) * 8]),
                    .iNum2(bias_in),

                    .oNum(tensor_out[(rowCnt * 8 + colCnt) * 8 + 7:(rowCnt * 8 + colCnt) * 8])
                    .overflow(8 * 8 + rowCnt * 8 + colCnt)
                );
            end
    endgenerate

    assign overflow = | overflows;
endmodule