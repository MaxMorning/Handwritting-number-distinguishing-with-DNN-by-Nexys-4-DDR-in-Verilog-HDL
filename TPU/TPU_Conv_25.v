module TPU_Conv_25(
    input [25 * 8 - 1:0] data_in1,
    input [25 * 8 - 1:0] data_in2,

    output [7:0] data_out,
    output overflow
);

    wire [49:0] overflows;
    wire [25 * 8 - 1:0] mult_out;
    wire [25 * 8 - 1:0] add_out;
    assign add_out[7:0] = mult_out[7:0];
    assign overflows[25] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin
            Float8Mult inst(
                .iNum1(data_in1[8 * i + 7: 8 * i]),
                .iNum2(data_in2[8 * i + 7: 8 * i]),
                .oNum(mult_out[8 * i + 7: 8 * i]),
                .overflow(overflows[i])
            );
        end

        for (i = 1; i < 25; i = i + 1) begin
            Float8Adder inst(
                .iNum1(add_out[8 * i - 1: 8 * i - 8]),
                .iNum2(mult_out[8 * i + 7:8 * i]),
                .oNum(add_out[8 * i + 7:8 * i]),
                .overflow(overflows[25 + i])
            );
        end
    endgenerate
    
    assign overflow = | overflows;
    assign data_out = add_out[25 * 8 - 1:25 * 8 - 8];
endmodule