module TPU_Conv_25(
    input [25 * 8 - 1:0] data_in1,
    input [25 * 8 - 1:0] data_in2,

    output [7:0] data_out,
    output overflow
);

    wire [24:0] overflows;
    wire [25 * 15 - 1:0] mult_out;
    wire [25 * 15 - 1:0] add_out;
    assign add_out[14:0] = mult_out[14:0];
    assign overflows[0] = 1'b0;
    
    generate
        genvar i;
        for (i = 0; i < 25; i = i + 1) begin : Mult
            Float8Mult inst(
                .iNum1(data_in1[8 * i + 7: 8 * i]),
                .iNum2(data_in2[8 * i + 7: 8 * i]),
                .oNum(mult_out[15 * i + 14: 15 * i])
            );
        end

        for (i = 1; i < 25; i = i + 1) begin : Add
            Float8Adder inst(
                .iNum1(add_out[15 * i - 1: 15 * i - 15]),
                .iNum2(mult_out[15 * i + 14:15 * i]),
                .oNum(add_out[15 * i + 14:15 * i]),
                .overflow(overflows[i])
            );
    end
    endgenerate
    
    assign overflow = | overflows;
    assign data_out = add_out[25 * 15 - 1:25 * 15 - 8];
endmodule