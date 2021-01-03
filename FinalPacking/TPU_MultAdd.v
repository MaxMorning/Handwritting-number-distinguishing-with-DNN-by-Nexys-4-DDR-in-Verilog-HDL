module TPU_MultAdd(
    input [128 * 8 - 1:0] data_in1,
    input [128 * 8 - 1:0] data_in2,

    output [14:0] data_out,
    output wire overflow
);

    wire [127:0] overflows;
    wire [128 * 15 - 1:0] mult_out;
    wire [128 * 15 - 1:0] add_out;
    assign add_out[14:0] = mult_out[14:0];
    assign overflows[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : MULT
            Float8Mult multInst(
                .iNum1(data_in1[i * 8 + 7:i * 8]),
                .iNum2(data_in2[i * 8 + 7:i * 8]),

                .oNum(mult_out[i * 15 + 14:i * 15])
            );
        end

        for (i = 1; i < 128; i = i + 1) begin : ADD
            Float8Adder inst(
                .iNum1(add_out[15 * i - 1: 15 * i - 15]),
                .iNum2(mult_out[15 * i + 14:15 * i]),
                .oNum(add_out[15 * i + 14:15 * i]),
                .overflow(overflows[i])
            );
        end
    endgenerate

    assign overflow = | overflows;
    assign data_out = add_out[128 * 15 - 1:128 * 15 - 8];
endmodule