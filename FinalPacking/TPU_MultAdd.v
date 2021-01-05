module TPU_MultAdd(
    input [128 * bit - 1:0] data_in1,
    input [128 * bit - 1:0] data_in2,

    output [(2 * bit - 2):0] data_out,
    output wire overflow
);

    wire [127:0] overflows;
    wire [128 * (2 * bit - 1) - 1:0] mult_out;
    wire [128 * (2 * bit - 1) - 1:0] add_out;
    assign add_out[(2 * bit - 2):0] = mult_out[(2 * bit - 2):0];
    assign overflows[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : MULT
            Float16Mult multInst(
                .iNum1(data_in1[i * bit + (bit - 1):i * bit]),
                .iNum2(data_in2[i * bit + (bit - 1):i * bit]),

                .oNum(mult_out[i * (2 * bit - 1) + (2 * bit - 2):i * (2 * bit - 1)])
            );
        end

        for (i = 1; i < 128; i = i + 1) begin : ADD
            Float16Adder inst(
                .iNum1(add_out[(2 * bit - 1) * i - 1: (2 * bit - 1) * i - (2 * bit - 1)]),
                .iNum2(mult_out[(2 * bit - 1) * i + (2 * bit - 2):(2 * bit - 1) * i]),
                .oNum(add_out[(2 * bit - 1) * i + (2 * bit - 2):(2 * bit - 1) * i]),
                .overflow(overflows[i])
            );
        end
    endgenerate

    assign overflow = | overflows;
    assign data_out = add_out[128 * (2 * bit - 1) - 1 -: (2 * bit - 1)];
endmodule