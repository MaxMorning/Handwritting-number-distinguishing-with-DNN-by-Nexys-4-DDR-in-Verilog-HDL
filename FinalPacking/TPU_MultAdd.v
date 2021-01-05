module TPU_MultAdd(
    input [128 * 16 - 1:0] data_in1,
    input [128 * 16 - 1:0] data_in2,

    output [30:0] data_out,
    output wire overflow
);

    wire [127:0] overflows;
    wire [128 * 31 - 1:0] mult_out;
    wire [128 * 31 - 1:0] add_out;
    assign add_out[30:0] = mult_out[30:0];
    assign overflows[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : MULT
            Float16Mult multInst(
                .iNum1(data_in1[i * 16 + 15:i * 16]),
                .iNum2(data_in2[i * 16 + 15:i * 16]),

                .oNum(mult_out[i * 31 + 30:i * 31])
            );
        end

        for (i = 1; i < 128; i = i + 1) begin : ADD
            Float16Adder inst(
                .iNum1(add_out[31 * i - 1: 31 * i - 31]),
                .iNum2(mult_out[31 * i + 30:31 * i]),
                .oNum(add_out[31 * i + 30:31 * i]),
                .overflow(overflows[i])
            );
        end
    endgenerate

    assign overflow = | overflows;
    assign data_out = add_out[128 * 31 - 1 -: 31];
endmodule